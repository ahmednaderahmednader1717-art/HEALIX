using HEALIX.API.Data;
using HEALIX.API.Services.Interfaces;
using HEALIX.Models.DTOs;
using HEALIX.Models.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace HEALIX.API.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly ITokenService _tokenService;

        public AuthService(ApplicationDbContext context, ITokenService tokenService)
        {
            _context = context;
            _tokenService = tokenService;
        }

        public async Task<AuthResponseDto> SignUpAsync(SignUpRequestDto request)
        {
            // Check if username exists
            var existingUsername = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == request.Username);

            if (existingUsername != null)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "Username already exists"
                };
            }

            // Check if email exists
            var existingEmail = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (existingEmail != null)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "Email already exists"
                };
            }

            // Hash password
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            // Create user
            var user = new User
            {
                Username = request.Username,
                Email = request.Email,
                PasswordHash = passwordHash,
                FullName = request.FullName,
                PhoneNumber = request.PhoneNumber,
                DateOfBirth = request.DateOfBirth,
                Gender = request.Gender,              
                LoginProvider = "Local",
                ProfilePictureUrl = request.ProfilePictureUrl,
                Height = request.Height,
                Weight = request.Weight,
                BodyType = request.BodyType,
                DietType = request.DietType,
                Goal = request.Goal,
                GoalWeight = request.GoalWeight,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            // Generate tokens
            var accessToken = _tokenService.GenerateAccessToken(user);
            var refreshToken = _tokenService.GenerateRefreshToken();
            await _tokenService.SaveRefreshTokenAsync(user.Id, refreshToken);

            return MapToAuthResponse(user, accessToken, refreshToken);

           
        }

        public async Task<AuthResponseDto> SignInAsync(SignInRequestDto request)
        {
            // Find user by username
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == request.Username);

            if (user == null)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "Invalid username or password"
                };
            }

            // Verify password
            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "Invalid username or password"
                };
            }

            // Check if account is active
            if (!user.IsActive)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "Account is disabled. Please contact support"
                };
            }

            // Update last login
            user.LastLogin = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // Generate tokens
            var accessToken = _tokenService.GenerateAccessToken(user);
            var refreshToken = _tokenService.GenerateRefreshToken();
            await _tokenService.SaveRefreshTokenAsync(user.Id, refreshToken);

            return new AuthResponseDto
            {
                Success = true,
                Message = "Login successful",
                User = MapToUserDto(user),
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                TokenExpiresAt = DateTime.UtcNow.AddMinutes(60)
            };
        }

        public async Task<AuthResponseDto> RefreshTokenAsync(string refreshToken)
        {
            var token = await _tokenService.GetRefreshTokenAsync(refreshToken);

            if (token == null || !token.IsActive)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "Invalid or expired refresh token"
                };
            }

            var user = token.User;

            // Revoke old token
            await _tokenService.RevokeRefreshTokenAsync(refreshToken);

            // Generate new tokens
            var newAccessToken = _tokenService.GenerateAccessToken(user);
            var newRefreshToken = _tokenService.GenerateRefreshToken();
            await _tokenService.SaveRefreshTokenAsync(user.Id, newRefreshToken);

            return new AuthResponseDto
            {
                Success = true,
                Message = "Token refreshed successfully",
                User = MapToUserDto(user),
                AccessToken = newAccessToken,
                RefreshToken = newRefreshToken,
                TokenExpiresAt = DateTime.UtcNow.AddMinutes(60)
            };
        }

        public async Task<bool> RevokeTokenAsync(string refreshToken)
        {
            return await _tokenService.RevokeRefreshTokenAsync(refreshToken);
        }

        public async Task<bool> ForgotPasswordAsync(string email)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
                return false;

            // Create reset token
            var resetToken = Guid.NewGuid().ToString();
            var passwordResetToken = new PasswordResetToken
            {
                UserId = user.Id,
                Token = resetToken,
                ExpiresAt = DateTime.UtcNow.AddHours(1),
                CreatedAt = DateTime.UtcNow
            };

            _context.PasswordResetTokens.Add(passwordResetToken);
            await _context.SaveChangesAsync();

            // TODO: Send email with reset link
            // sendEmail(user.Email, resetToken);

            return true;
        }

        public async Task<bool> ResetPasswordAsync(ResetPasswordRequestDto request)
        {
            var resetToken = await _context.PasswordResetTokens
                .Include(t => t.User)
                .FirstOrDefaultAsync(t => t.Token == request.Token);

            if (resetToken == null || !resetToken.IsValid)
                return false;

            // Update password
            var user = resetToken.User;
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;

            // Mark token as used
            resetToken.IsUsed = true;

            // Revoke all refresh tokens
            var userTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == user.Id && !rt.IsRevoked)
                .ToListAsync();

            foreach (var token in userTokens)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            return true;
        }

        // ✅ جديد: External Login Method
        public async Task<AuthResponseDto> ExternalLoginAsync(ExternalLoginRequestDto request)
        {
            // تحقق: المستخدم موجود؟
            var existingUser = await _context.Users
                .FirstOrDefaultAsync(u =>
                    u.LoginProvider == request.Provider &&
                    u.ExternalId == request.ExternalId
                );

            if (existingUser != null)
            {
                // المستخدم موجود - تسجيل دخول
                existingUser.LastLogin = DateTime.UtcNow;

                // تحديث الصورة لو اتغيرت
                if (!string.IsNullOrEmpty(request.ProfilePictureUrl))
                {
                    existingUser.ProfilePictureUrl = request.ProfilePictureUrl;
                }

                await _context.SaveChangesAsync();

                var accessToken = _tokenService.GenerateAccessToken(existingUser);
                var refreshToken = _tokenService.GenerateRefreshToken();
                await _tokenService.SaveRefreshTokenAsync(existingUser.Id, refreshToken);

                // ✅ استخدم Helper Method
                return MapToAuthResponse(existingUser, accessToken, refreshToken);
            }

            // تحقق: الإيميل موجود بـ provider تاني؟
            var emailExists = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (emailExists != null)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = $"Email already registered with {emailExists.LoginProvider} login"
                };
            }

            // إنشاء مستخدم جديد
            var username = await GenerateUniqueUsernameFromEmail(request.Email);

            var newUser = new User
            {
                Username = username,
                Email = request.Email,
                FullName = request.FullName,
                DateOfBirth = request.DateOfBirth,
                Gender = request.Gender,
                LoginProvider = request.Provider,
                ExternalId = request.ExternalId,
                ProfilePictureUrl = request.ProfilePictureUrl,
                IsEmailVerified = true,  // Google/Apple emails verified
                PasswordHash = null,  // No password for external login
                Height = request.Height,
                Weight = request.Weight,
                BodyType = request.BodyType,
                DietType = request.DietType,
                Goal = request.Goal,
                GoalWeight = request.GoalWeight,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                LastLogin = DateTime.UtcNow
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            var newAccessToken = _tokenService.GenerateAccessToken(newUser);
            var newRefreshToken = _tokenService.GenerateRefreshToken();
            await _tokenService.SaveRefreshTokenAsync(newUser.Id, newRefreshToken);

            // ✅ استخدم Helper Method
            return MapToAuthResponse(newUser, newAccessToken, newRefreshToken);
        }

        // ✅ Helper Method: توليد username من email
        private async Task<string> GenerateUniqueUsernameFromEmail(string email)
        {
            // خذ الجزء قبل @
            var baseUsername = email.Split('@')[0].ToLower();

            // امسح أي حروف غريبة
            baseUsername = new string(baseUsername.Where(c => char.IsLetterOrDigit(c) || c == '_').ToArray());

            var username = baseUsername;
            var counter = 1;

            // لو Username موجود، أضف رقم
            while (await _context.Users.AnyAsync(u => u.Username == username))
            {
                username = $"{baseUsername}{counter}";
                counter++;
            }

            return username;
        }
        public async Task<bool> UpdateProfilePictureAsync(int userId, string profilePictureUrl)
        {
            // جيب المستخدم من Database
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                return false;

            // حدث الصورة
            user.ProfilePictureUrl = profilePictureUrl;
            user.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        } 
        /// <summary>
        /// تحديث البيانات الصحية للمستخدم
        /// 
        /// الاستخدام:
        /// - User سجل ومكملش بياناته → يكملها بعدين
        /// - User عايز يحدث وزنه أو هدفه
        /// </summary>
        public async Task<bool> UpdateHealthProfileAsync(int userId, UpdateHealthProfileDto request)
        {
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                return false;

            // Update fields (بس اللي موجودة في الـ request)
            if (request.Height.HasValue)
                user.Height = request.Height.Value;

            if (request.Weight.HasValue)
                user.Weight = request.Weight.Value;

            if (!string.IsNullOrEmpty(request.BodyType))
                user.BodyType = request.BodyType;

            if (!string.IsNullOrEmpty(request.DietType))
                user.DietType = request.DietType;

            if (!string.IsNullOrEmpty(request.Goal))
                user.Goal = request.Goal;

            if (request.GoalWeight.HasValue)
                user.GoalWeight = request.GoalWeight.Value;

            user.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }
        // ✅ أضف الـ 2 Methods دول في آخر AuthService class

        /// <summary>
        /// Check if user has completed their health profile
        /// </summary>
        private bool IsHealthProfileComplete(User user)
        {
            return user.Height.HasValue &&
                   user.Weight.HasValue &&
                   !string.IsNullOrEmpty(user.BodyType) &&
                   !string.IsNullOrEmpty(user.DietType) &&
                   !string.IsNullOrEmpty(user.Goal) &&
                   user.GoalWeight.HasValue;
        }

        /// <summary>
        /// Map User to AuthResponse with IsProfileComplete flag
        /// </summary>
        private AuthResponseDto MapToAuthResponse(User user, string accessToken, string refreshToken)
        {
            return new AuthResponseDto
            {
                Success = true,
                Message = "Login successful",
                User = MapToUserDto(user),
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                TokenExpiresAt = DateTime.UtcNow.AddMinutes(60),
                IsProfileComplete = IsHealthProfileComplete(user)
            };
        }



        private UserDto MapToUserDto(User user)
        {
            return new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                Email = user.Email,
                FullName = user.FullName,
                PhoneNumber = user.PhoneNumber,
                DateOfBirth = user.DateOfBirth,
                Gender = user.Gender,
                LoginProvider = user.LoginProvider,
                ProfilePictureUrl = user.ProfilePictureUrl,
                Height = user.Height,
                Weight = user.Weight,
                BodyType = user.BodyType,
                DietType = user.DietType,
                Goal = user.Goal,
                GoalWeight = user.GoalWeight,
                IsEmailVerified = user.IsEmailVerified,
                CreatedAt = user.CreatedAt,
                LastLogin = user.LastLogin
            };
        }

    }
}