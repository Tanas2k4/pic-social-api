using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.Services;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models.Entities;
using Microsoft.Identity.Client;
using Microsoft.EntityFrameworkCore;
namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PostController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly GoogleCloudStorageService _googleCloudStorageService;
        private readonly UserManager<ApplicationUser> _userManager;

        public PostController(ApplicationDbContext context, GoogleCloudStorageService googleCloudStorageService, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _googleCloudStorageService = googleCloudStorageService;
            _userManager = userManager;
        }

        //POST api/post/upload
        [HttpPost("upload")]
        public async Task<IActionResult> UploadPhoto([FromForm] string title, [FromForm] List<IFormFile> files)
        {
            //Kiểm tra files được tải lên
            if (files == null || files.Count == 0)
                return BadRequest("No files uploaded.");

            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            //Tao Post mới
            var post = new Post
            {
                UserId = user.Id,
                Title = title,
                CreatedDate = DateTimeOffset.Now
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
                    OriginalFileUrl = fileUrl,
                    CreatedDate = DateTimeOffset.Now,
                    IsPublic = true
                };

                post.Photos.Add(photo);
            }

            _context.Posts.Add(post);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                postId = post.PostId,
                userId = post.UserId,
                title = post.Title,
                createdDate = post.CreatedDate,
                photo = post.Photos.Select(p => new
                {
                    photoId = p.PhotoId,
                    originalFileUrl = p.OriginalFileUrl,
                    isPublic = p.IsPublic
                })
            });
        }

        //DELETE api/post/delete/{postId}
        [HttpDelete("delete/{postId}")]
        public async Task<IActionResult> DeletePost(Guid postId)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            var post = await _context.Posts
                .Include(p => p.Photos)
                .FirstOrDefaultAsync(p => p.PostId == postId && p.UserId == user.Id);

            if (post == null)
                return NotFound("Post not found or you do not have permission to delete this post.");

            //Xoa anh tren Google Cloud Storage
            foreach (var photo in post.Photos)
            {
                var objectName = new Uri(photo.OriginalFileUrl).Segments.Last();
                await _googleCloudStorageService.DeleteFileAsync(objectName);
            }

            //Xoa Post va anh trong database
            _context.Posts.Remove(post);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Post and associated photos deleted successfully." });
        }

        //PUT api/post/update/{postId}
        [HttpPut("update/{postId}")]
        public async Task<IActionResult> UpdatePost(Guid postId, [FromBody] UpdatePostDto updatePostDto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId && p.UserId == user.Id);

            if (post == null)
                return NotFound("Post not found or you do not have permission to update this post.");

            post.Title = updatePostDto.Title;
            post.UpdatedDate = DateTimeOffset.Now;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                postId = post.PostId,
                userId = post.UserId,
                title = post.Title,
                createdDate = post.CreatedDate,
                updatedDate = post.UpdatedDate
            });
        }

        //GET api/post/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetPostsByUser(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
                return NotFound("User not found.");

            var posts = await _context.Posts
                .Where(p => p.UserId == id)
                .Select(p => new
                {
                    postId = p.PostId,
                    userId = p.UserId,
                    title = p.Title,
                    createdDate = p.CreatedDate,
                    photos = p.Photos.Select(photo => new
                    {
                        photoId = photo.PhotoId,
                        originalFileUrl = photo.OriginalFileUrl,
                        isPublic = photo.IsPublic
                    })
                })
                .ToListAsync();

            return Ok(posts);
        }

        //GET api/post/view/{postId}
        [HttpGet("view/{postId}")]
        public async Task<IActionResult> GetPost(Guid postId)
        {
            var post = await _context.Posts
                .Where(p => p.PostId == postId)
                .Select(p => new
                {
                    postId = p.PostId,
                    userId = p.UserId,
                    title = p.Title,
                    createdDate = p.CreatedDate,
                    photos = p.Photos.Select(photo => new
                    {
                        photoId = photo.PhotoId,
                        originalFileUrl = photo.OriginalFileUrl,
                        isPublic = photo.IsPublic
                    })
                })
                .FirstOrDefaultAsync();

            if (post == null)
                return Ok(new { message = "Post not found." });

            return Ok(post);
        }
    }
}   
