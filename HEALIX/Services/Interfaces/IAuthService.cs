using HEALIX.Models.DTOs;

namespace HEALIX.API.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponseDto> SignUpAsync(SignUpRequestDto request);
        Task<AuthResponseDto> SignInAsync(SignInRequestDto request);
        Task<AuthResponseDto> ExternalLoginAsync(ExternalLoginRequestDto request);
        Task<AuthResponseDto> RefreshTokenAsync(string refreshToken);
        Task<bool> RevokeTokenAsync(string refreshToken);
        Task<bool> ForgotPasswordAsync(string email);
        Task<bool> ResetPasswordAsync(ResetPasswordRequestDto request);
        Task<bool> UpdateProfilePictureAsync(int userId, string profilePictureUrl);
        Task<bool> UpdateHealthProfileAsync(int userId, UpdateHealthProfileDto request);
    }
}