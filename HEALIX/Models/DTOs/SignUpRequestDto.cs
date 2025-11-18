using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{

    // Sign Up Request
    public class SignUpRequestDto
    {
        [Required(ErrorMessage = "Username is required")]
        [MinLength(3, ErrorMessage = "Username must be at least 3 characters")]
        [MaxLength(50, ErrorMessage = "Username cannot exceed 50 characters")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "Username can only contain letters, numbers and underscores")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required")]
        [MinLength(6, ErrorMessage = "Password must be at least 6 characters")]
        public string Password { get; set; }

        [Required(ErrorMessage = "Full name is required")]
        [MinLength(3, ErrorMessage = "Full name must be at least 3 characters")]
        public string FullName { get; set; }

        [Phone(ErrorMessage = "Invalid phone number")]
        public string? PhoneNumber { get; set; }


        [MaxLength(500)]
        [Url (ErrorMessage ="Invalid Url Format")]
        public string? ProfilePictureUrl { get; set; }

        [Range(50, 300, ErrorMessage = "Height must be between 50 and 300 cm")]
        public decimal? Height { get; set; }

        [Range(20, 500, ErrorMessage = "Weight must be between 20 and 500 kg")]
        public decimal? Weight { get; set; }

        [MaxLength(20)]
        public string? BodyType { get; set; } // Ectomorph, Mesomorph, Endomorph

        [MaxLength(20)]
        public string? DietType { get; set; } // Vegan, Vegetarian, Pescatarian, Standard

        [MaxLength(20)]
        public string? Goal { get; set; } // GainWeight, MaintainWeight, LoseWeight

        [Range(20, 500, ErrorMessage = "Goal weight must be between 20 and 500 kg")]
        public decimal? GoalWeight { get; set; }

        public DateTime? DateOfBirth { get; set; }

        public string? Gender { get; set; }
    }
}
