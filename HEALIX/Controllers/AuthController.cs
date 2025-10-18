using HEALIX.API.Services.Interfaces;
using HEALIX.Models.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HEALIX.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
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

        
        [Authorize]
        [HttpGet("verify")]
        public IActionResult VerifyToken()
        {
            return Ok(new
            {
                message = "Token is valid",
                userId = User.FindFirst("userId")?.Value,
                username = User.FindFirst("username")?.Value
            });
        }
    }
}