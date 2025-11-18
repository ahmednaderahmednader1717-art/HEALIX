
using System.ComponentModel.DataAnnotations;

namespace HEALIX.Models.DTOs
{
    // User DTO
    public class UserDto
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public string? PhoneNumber { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? LoginProvider { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
        public string? BodyType { get; set; }
        public string? DietType { get; set; }
        public string? Goal { get; set; } //lose or gain or maintain weight
        public decimal? GoalWeight { get; set; }
        public bool IsEmailVerified { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLogin { get; set; }
    }
}
