using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{
    // Forgot Password Request
    public class ForgotPasswordRequestDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
    }
}
