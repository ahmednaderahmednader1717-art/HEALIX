using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{
    // Refresh Token Request
    public class RefreshTokenRequestDto
    {
        [Required]
        public string RefreshToken { get; set; }
    }
}
