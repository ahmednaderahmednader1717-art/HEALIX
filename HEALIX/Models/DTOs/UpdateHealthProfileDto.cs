using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{
    public class UpdateHealthProfileDto
    {
        [Range(50, 300, ErrorMessage = "Height must be between 50 and 300 cm")]
        public decimal? Height { get; set; }

        [Range(20, 500, ErrorMessage = "Weight must be between 20 and 500 kg")]
        public decimal? Weight { get; set; }

        [MaxLength(20)]
        public string? BodyType { get; set; }

        [MaxLength(20)]
        public string? DietType { get; set; }

        [MaxLength(50)]
        public string? Goal { get; set; }

        [Range(20, 500, ErrorMessage = "Goal weight must be between 20 and 500 kg")]
        public decimal? GoalWeight { get; set; }
    }
}
