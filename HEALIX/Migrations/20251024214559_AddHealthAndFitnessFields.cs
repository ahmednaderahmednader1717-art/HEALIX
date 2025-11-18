using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HEALIX.Migrations
{
    /// <inheritdoc />
    public partial class AddHealthAndFitnessFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BodyType",
                table: "Users",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DietType",
                table: "Users",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Goal",
                table: "Users",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "GoalWeight",
                table: "Users",
                type: "decimal(5,2)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Height",
                table: "Users",
                type: "decimal(5,2)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Weight",
                table: "Users",
                type: "decimal(5,2)",
                nullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_User_BodyType",
                table: "Users",
                sql: "BodyType IS NULL OR BodyType IN ('Ectomorph', 'Mesomorph', 'Endomorph')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_User_DietType",
                table: "Users",
                sql: "DietType IS NULL OR DietType IN ('Vegan', 'Vegetarian', 'Pescatarian', 'Standard')");

            migrationBuilder.AddCheckConstraint(
                name: "CK_User_Goal",
                table: "Users",
                sql: "Goal IS NULL OR Goal IN ('GainWeight', 'MaintainWeight', 'LoseWeight')");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_User_BodyType",
                table: "Users");

            migrationBuilder.DropCheckConstraint(
                name: "CK_User_DietType",
                table: "Users");

            migrationBuilder.DropCheckConstraint(
                name: "CK_User_Goal",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "BodyType",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DietType",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Goal",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "GoalWeight",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Height",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Weight",
                table: "Users");
        }
    }
}
