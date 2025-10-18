using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{
    // Reset Password Request
    public class ResetPasswordRequestDto
    {
        [Required]
        public string Token { get; set; }

        [Required]
        [MinLength(6)]
        public string NewPassword { get; set; }
    }
}
