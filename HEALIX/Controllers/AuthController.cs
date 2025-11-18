using HEALIX.API.Services.Interfaces;
using HEALIX.Models.DTOs;
using HEALIX.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HEALIX.API.Data;

namespace HEALIX.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ApplicationDbContext _context;

        public AuthController(IAuthService authService, ApplicationDbContext context)
        {
            _authService = authService;
            _context = context;
        }


        [HttpPost("signup")]
        public async Task<IActionResult> SignUp([FromBody] SignUpRequestDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.SignUpAsync(request);

            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }


        [HttpPost("signin")]
        public async Task<IActionResult> SignIn([FromBody] SignInRequestDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.SignInAsync(request);

            if (!result.Success)
                return Unauthorized(result);

            return Ok(result);
        }


        [HttpPost("refresh")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDto request)
        {
            var result = await _authService.RefreshTokenAsync(request.RefreshToken);

            if (!result.Success)
                return Unauthorized(result);

            return Ok(result);
        }


        [Authorize]
        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] RefreshTokenRequestDto request)
        {
            var result = await _authService.RevokeTokenAsync(request.RefreshToken);

            if (!result)
                return BadRequest(new { message = "Logout failed" });

            return Ok(new { message = "Logout successful" });
        }


        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequestDto request)
        {
            var result = await _authService.ForgotPasswordAsync(request.Email);

            // Always return success for security
            return Ok(new
            {
                message = "If the email exists, a password reset link has been sent"
            });
        }


        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequestDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.ResetPasswordAsync(request);

            if (!result)
                return BadRequest(new { message = "Invalid or expired token" });

            return Ok(new { message = "Password reset successful" });
        }


        //[Authorize]
        //[HttpGet("verify")]
        //public IActionResult VerifyToken()
        //{
        //    return Ok(new
        //    {
        //        message = "Token is valid",
        //        userId = User.FindFirst("userId")?.Value,
        //        username = User.FindFirst("username")?.Value
        //    });
        //}


        [HttpPost("external-login")]
        public async Task<IActionResult> ExternalLogin([FromBody] ExternalLoginRequestDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _authService.ExternalLoginAsync(request);

            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        [Authorize]
        [HttpPut("update-profile-picture")]
        public async Task<IActionResult> UpdateProfilePicture([FromBody] UpdateProfilePictureDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // جيب الـ User ID من الـ JWT Token
            var userIdClaim = User.FindFirst("userId")?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            // حدث الصورة
            var result = await _authService.UpdateProfilePictureAsync(userId, request.ProfilePictureUrl);

            if (!result)
            {
                return NotFound(new { message = "User not found" });
            }

            return Ok(new
            {
                message = "Profile picture updated successfully",
                profilePictureUrl = request.ProfilePictureUrl
            });
        }

        [Authorize]
        [HttpPut("update-health-profile")]
        public async Task<IActionResult> UpdateHealthProfile([FromBody] UpdateHealthProfileDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userIdClaim = User.FindFirst("userId")?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var result = await _authService.UpdateHealthProfileAsync(userId, request);

            if (!result)
            {
                return NotFound(new { message = "User not found" });
            }

            var user = await _context.Users.FindAsync(userId);
            var isComplete = user != null && IsHealthProfileComplete(user);

            return Ok(new { 
                message = "Health profile updated successfully",
                isProfileComplete = isComplete
            });
        }
        /// <summary>
        /// Verify if JWT token is valid
        /// Flutter uses this to check if user is still logged in
        /// </summary>
        [Authorize]
        [HttpGet("verify-token")]
        public async Task<IActionResult> VerifyToken()
        {
            var userIdClaim = User.FindFirst("userId")?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { valid = false, message = "Invalid token" });
            }

            // جيب User من Database
            var user = await _context.Users.FindAsync(userId);

            if (user == null || !user.IsActive)
            {
                return Unauthorized(new { valid = false, message = "User not found or inactive" });
            }

            return Ok(new
            {
                valid = true,
                userId = user.Id,
                username = user.Username,
                email = user.Email,
                isProfileComplete = IsHealthProfileComplete(user),
                message = "Token is valid"
            });
        }

        // ✅ أضف الـ Method دي
        private bool IsHealthProfileComplete(User user)
        {
            return user.Height.HasValue &&
                   user.Weight.HasValue &&
                   !string.IsNullOrEmpty(user.BodyType) &&
                   !string.IsNullOrEmpty(user.DietType) &&
                   !string.IsNullOrEmpty(user.Goal) &&
                   user.GoalWeight.HasValue;
        }
    }
}
