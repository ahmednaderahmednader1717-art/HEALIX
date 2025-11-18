using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{
    public class ExternalLoginRequestDto
    {
        [Required(ErrorMessage = "Provider is required")]
        public string Provider { get; set; }

        [Required(ErrorMessage = "External Id is required")]
        public string ExternalId { get; set; }

        [Required(ErrorMessage = "Email is required")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Full name is required")]
        public string FullName { get; set; }
        public string? ProfilePictureUrl { get; set; }
         
        public DateTime? DateOfBirth { get; set; }

        public string? Gender { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
        public string? BodyType { get; set; }
        public string? DietType { get; set; }
        public string? Goal { get; set; }
        public decimal? GoalWeight { get; set; }


    }
}
