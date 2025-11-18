using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{
    public class UpdateProfilePictureDto
    {
        [MaxLength(500)]
        [Url (ErrorMessage = "Invalid Url Format")]
        [Required(ErrorMessage = "Profile picture URL is required")]
        public string? ProfilePictureUrl { get; set; }
    }
}
