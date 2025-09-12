using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.Services;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models.Entities;
namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PhotoController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly GoogleCloudStorageService _googleCloudStorageService;
        private readonly UserManager<ApplicationUser> _userManager;

        public PhotoController(ApplicationDbContext context, GoogleCloudStorageService googleCloudStorageService, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _googleCloudStorageService = googleCloudStorageService;
            _userManager = userManager;
        }

        //POST api/photo/upload
        [HttpPost("upload")]
        public async Task<IActionResult> UploadPhoto([FromForm] string title, [FromForm] List<IFormFile> files)
        {
            //Kiem tra file hop le
            if (files == null || files.Count == 0)
                return BadRequest("No files uploaded.");

            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            //Tao post response
            var postResponse = new PostResponseDto
            {
                UserName = user.UserName!,
                Title = title,
                CreateDate = DateTimeOffset.UtcNow
            };

            //Upload tung file len Google Cloud Storage va luu vao database
            foreach (var file in files)
            {
                var objectName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
                var fileUrl = await _googleCloudStorageService
                    .UploadFileAsync(file.OpenReadStream(), objectName, file.ContentType);

                var photo = new Photo
                {
                    UserId = user.Id,
                    Title = title,
                    OriginalFileUrl = fileUrl,
                    CreatedDate = DateTimeOffset.UtcNow,
                    IsPublic = true
                };

                _context.Photos.Add(photo);

                postResponse.Photos.Add(new PhotoDto
                {
                    PhotoId = photo.PhotoId,
                    OriginalFileUrl = photo.OriginalFileUrl
                });
            }

            await _context.SaveChangesAsync();

            return Ok(postResponse);
        }
    }
}