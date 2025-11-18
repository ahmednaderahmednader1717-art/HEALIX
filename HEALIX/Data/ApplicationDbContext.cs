using HEALIX.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace HEALIX.API.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<EmailVerificationToken> EmailVerificationTokens { get; set; }
        public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // User Configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("Users");

                entity.HasKey(e => e.Id);

                // 🆕 NEW: Health & Fitness Fields Configuration

                entity.Property(e => e.Height)
                      .HasColumnType("decimal(5,2)"); // 999.99 cm max
                                                      // مثال: 175.50

                entity.Property(e => e.Weight)
                      .HasColumnType("decimal(5,2)"); // 999.99 kg max
                                                      // مثال: 75.30

                entity.Property(e => e.BodyType)
                      .HasMaxLength(20);

                entity.Property(e => e.DietType)
                      .HasMaxLength(20);

                entity.Property(e => e.Goal)
                      .HasMaxLength(20);

                entity.Property(e => e.GoalWeight)
                      .HasColumnType("decimal(5,2)");

                // 🆕 Check Constraints (قيود للتأكد من القيم الصحيحة)

                entity.HasCheckConstraint("CK_User_BodyType",
                    "BodyType IS NULL OR BodyType IN ('Ectomorph', 'Mesomorph', 'Endomorph')");

                entity.HasCheckConstraint("CK_User_DietType",
                    "DietType IS NULL OR DietType IN ('Vegan', 'Vegetarian', 'Pescatarian', 'Standard')");

                entity.HasCheckConstraint("CK_User_Goal",
                    "Goal IS NULL OR Goal IN ('GainWeight', 'MaintainWeight', 'LoseWeight')");


                // Username
                entity.Property(e => e.Username)
                      .IsRequired()
                      .HasMaxLength(50);

                entity.HasIndex(e => e.Username)
                      .IsUnique();

                // Email
                entity.Property(e => e.Email)
                      .IsRequired()
                      .HasMaxLength(255);

                entity.HasIndex(e => e.Email)
                      .IsUnique();

                entity.Property(e => e.PasswordHash)
                      .HasMaxLength(500);

                entity.Property(e => e.FullName)
                      .IsRequired()
                      .HasMaxLength(100);

                entity.Property(e => e.PhoneNumber)
                      .HasMaxLength(20);

                entity.Property(e => e.Gender)
                      .HasMaxLength(10);

                entity.Property(e => e.LoginProvider)
                       .HasMaxLength(20);

                entity.Property(e => e.ExternalId)
                      .HasMaxLength(500);

                entity.Property(e => e.ProfilePictureUrl)
                      .HasMaxLength(500);

                entity.HasIndex(e => new { e.LoginProvider, e.ExternalId });

                entity.Property(e => e.IsEmailVerified)
                      .HasDefaultValue(false);

                entity.Property(e => e.IsActive)
                      .HasDefaultValue(true);

                entity.Property(e => e.CreatedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.Property(e => e.UpdatedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.HasCheckConstraint("CK_User_Gender",
                    "Gender IS NULL OR Gender IN ('Male', 'Female', 'Other')");
            });

            // RefreshToken Configuration
            modelBuilder.Entity<RefreshToken>(entity =>
            {
                entity.ToTable("RefreshTokens");

                entity.HasKey(e => e.Id);

                entity.Property(e => e.Token)
                      .IsRequired()
                      .HasMaxLength(500);

                entity.HasIndex(e => e.Token)
                      .IsUnique();

                entity.HasIndex(e => e.UserId);

                entity.Property(e => e.IsRevoked)
                      .HasDefaultValue(false);

                entity.Property(e => e.CreatedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(e => e.User)
                      .WithMany(u => u.RefreshTokens)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // EmailVerificationToken Configuration
            modelBuilder.Entity<EmailVerificationToken>(entity =>
            {
                entity.ToTable("EmailVerificationTokens");

                entity.HasKey(e => e.Id);

                entity.Property(e => e.Token)
                      .IsRequired()
                      .HasMaxLength(500);

                entity.HasIndex(e => e.Token)
                      .IsUnique();

                entity.Property(e => e.IsUsed)
                      .HasDefaultValue(false);

                entity.Property(e => e.CreatedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(e => e.User)
                      .WithMany(u => u.EmailVerificationTokens)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // PasswordResetToken Configuration
            modelBuilder.Entity<PasswordResetToken>(entity =>
            {
                entity.ToTable("PasswordResetTokens");

                entity.HasKey(e => e.Id);

                entity.Property(e => e.Token)
                      .IsRequired()
                      .HasMaxLength(500);

                entity.HasIndex(e => e.Token)
                      .IsUnique();

                entity.Property(e => e.IsUsed)
                      .HasDefaultValue(false);

                entity.Property(e => e.CreatedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(e => e.User)
                      .WithMany(u => u.PasswordResetTokens)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // AuditLog Configuration
            modelBuilder.Entity<AuditLog>(entity =>
            {
                entity.ToTable("AuditLogs");

                entity.HasKey(e => e.Id);

                entity.Property(e => e.Action)
                      .IsRequired()
                      .HasMaxLength(100);

                entity.Property(e => e.IpAddress)
                      .HasMaxLength(50);

                entity.Property(e => e.UserAgent)
                      .HasMaxLength(500);

                entity.Property(e => e.CreatedAt)
                      .HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(e => e.User)
                      .WithMany(u => u.AuditLogs)
                      .HasForeignKey(e => e.UserId)
                      .OnDelete(DeleteBehavior.SetNull);
            });
        }
    }
}