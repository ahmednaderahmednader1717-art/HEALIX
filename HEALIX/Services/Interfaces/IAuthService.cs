using HEALIX.Models.DTOs;

namespace HEALIX.API.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponseDto> SignUpAsync(SignUpRequestDto request);
        Task<AuthResponseDto> SignInAsync(SignInRequestDto request);
        Task<AuthResponseDto> RefreshTokenAsync(string refreshToken);
        Task<bool> RevokeTokenAsync(string refreshToken);
        Task<bool> ForgotPasswordAsync(string email);
        Task<bool> ResetPasswordAsync(ResetPasswordRequestDto request);
    }
}