using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HEALIX.API.Data;
using System.IO;

namespace HEALIX.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _env;

        public UserController(ApplicationDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        
        [Authorize]
        [HttpPost("upload-profile-picture")]
        public async Task<IActionResult> UploadProfilePicture(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { message = "No file uploaded" });

            // اسم المستخدم الحالي من الـ Token
            var userId = User.FindFirst("userId")?.Value;
            if (userId == null)
                return Unauthorized(new { message = "Unauthorized" });

            var user = await _context.Users.FindAsync(int.Parse(userId));
            if (user == null)
                return NotFound(new { message = "User not found" });

            // فولدر التخزين
            var uploadsFolder = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "uploads");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            // اسم الصورة الجديد
            var uniqueFileName = $"{Guid.NewGuid()}_{Path.GetFileName(file.FileName)}";
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            // احفظ الصورة
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // اللينك العام للصورة
            var imageUrl = $"{Request.Scheme}://{Request.Host}/uploads/{uniqueFileName}";

            // حفظ اللينك في الداتا بيز
            user.ProfilePictureUrl = imageUrl;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Profile picture uploaded successfully",
                imageUrl
            });
        }
    }
}
