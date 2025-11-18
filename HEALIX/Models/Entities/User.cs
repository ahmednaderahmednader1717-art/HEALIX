
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HEALIX.Models.Entities
{
    public class User
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Username { get; set; }

        [Required]
        [MaxLength(255)]
        [EmailAddress]
        public string Email { get; set; }

        
        [MaxLength(500)]
        public string? PasswordHash { get; set; }

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; }

        [MaxLength(20)]
        public string? PhoneNumber { get; set; }

        public DateTime? DateOfBirth { get; set; }

        [MaxLength(10)]
        public string? Gender { get; set; }

        [MaxLength(20)]
        public string? LoginProvider { get; set; }

        [MaxLength(500)]
        public string? ExternalId { get; set; }

        [MaxLength(500)]
        public string? ProfilePictureUrl { get; set; }

        public decimal? Height { get; set; }

        public decimal? Weight { get; set; }

        [MaxLength(20)]
        public string? BodyType { get; set; }

        [MaxLength(20)]
        public string? DietType { get; set; }

        [MaxLength(50)]
        public string? Goal { get; set; } //lose or gain or maintain weight

        public decimal? GoalWeight { get; set; }

        public bool IsEmailVerified { get; set; } = false;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? LastLogin { get; set; }

        // Navigation Properties
        public virtual ICollection<RefreshToken> RefreshTokens { get; set; }
        public virtual ICollection<EmailVerificationToken> EmailVerificationTokens { get; set; }
        public virtual ICollection<PasswordResetToken> PasswordResetTokens { get; set; }
        public virtual ICollection<AuditLog> AuditLogs { get; set; }
    }
}