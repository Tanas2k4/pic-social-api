using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using PicSocial.Server.DTOs.PostsDto;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;
using System.ComponentModel;

namespace PicSocial.Server.Services.Implementations
{
    public class PostService : IPostService
    {
        private readonly ApplicationDbContext _context;
        private readonly GoogleCloudStorageService _googleCloudStorageService;
        private readonly UserManager<ApplicationUser> _userManager;

        public PostService(ApplicationDbContext context, GoogleCloudStorageService googleCloudStorageService, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _googleCloudStorageService = googleCloudStorageService;
            _userManager = userManager;
        }

        //post a post
        public async Task<Results<PostResponseDto>> UploadPhotoAsync(string currentUserId, string? title, List<IFormFile> files, Guid? licenseId)
        {
            //kiểm tra files được tải lên
            if (files == null || files.Count == 0)
                return Results<PostResponseDto>.Bad("No files uploaded.");

            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Results<PostResponseDto>.Unauthorized("User not found");

            //(Optional) tùy chọn 1 value trong License
            var license = licenseId.HasValue ? await _context.Licenses.FindAsync(licenseId.Value) : null;
            if (licenseId.HasValue && license == null)
                return Results<PostResponseDto>.Bad("Licences not found");
            // Nếu client không gửi license → lấy mặc định "All Rights Reserved"
            if (!licenseId.HasValue)
            {
                license = await _context.Licenses
                    .FirstOrDefaultAsync(x => x.Name == "Royalty-Free");

                if (license == null)
                    return Results<PostResponseDto>.Bad("Default license 'Royalty-Free' not found in database.");

                licenseId = license.LicenseId; // GÁN vào licenseId của POST
            }
        
            // Create new post
            var post = new Post
            {
                UserId = currentUser.Id,
                Title = title,
                LicenseId = licenseId,
                CreatedDate = DateTimeOffset.Now
            }; 

            // Upload each file to Google Cloud Storage and save to database
            foreach (var file in files)
            {
                var objectName = $"Post/{currentUser.Id}/{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";

                var fileUrl = await _googleCloudStorageService.UploadFileAsync(
                    file.OpenReadStream(),
                    objectName,
                    file.ContentType
                );
                
                post.Photos.Add(new Photo
                {
                    UserId = currentUser.Id,
                    OriginalFileUrl = fileUrl,
                    CreatedDate = DateTimeOffset.Now,
                    IsPublic = true                   
                });
            }

            _context.Posts.Add(post);
            await _context.SaveChangesAsync();

    
            var dto = new PostResponseDto
            {
                PostId = post.PostId,
                UserId = post.UserId,
                Title = post.Title,
                CreatedDate = post.CreatedDate,
                LicenseName = license?.Name,
                Photos = post.Photos.Select(p => new PostPhotoDto
                {
                    PhotoId = p.PhotoId,
                    OriginalFileUrl = p.OriginalFileUrl,
                    IsPublic = p.IsPublic
                }).ToList(),
                UpdatedDate = post.UpdatedDate
            };

            return Results<PostResponseDto>.Ok(dto);
        }

        //delete post
        public async Task<Result> DeletePostAsync(Guid postId, string currentUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Result.Unauthorized("User not found");

            //Kiểm tra Post tồn tại và thuộc về user hiện tại
            var post = await _context.Posts
                .Include(p => p.Photos)
                .FirstOrDefaultAsync(p => p.PostId == postId && p.UserId == currentUserId);
            if (post == null)
                return Result.NotFound("Post not found");

            //Kiểm tra role Admin       
            var isAdmin = await _userManager.IsInRoleAsync(currentUser!, "Admin");
            if (!isAdmin && post.UserId != currentUserId)
                return Result.Forbidden("you don't have permission");
            //Xoa anh tren Google Cloud Storage
            foreach (var photo in post.Photos)
            {
                var objectName = new Uri(photo.OriginalFileUrl).Segments.Last();
                await _googleCloudStorageService.DeleteFileAsync(objectName);
            }

            //Xoa Post va anh trong database
            _context.Posts.Remove(post);
            await _context.SaveChangesAsync();
            return Result.Ok("Post and associated photos deleted successfully.");
        }

        //update post 
        public async Task<Results<PostResponseDto>> UpdatePostAsync(Guid postId, string currentUserId, string? newTitle, Guid? licenseId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Results<PostResponseDto>.Unauthorized("User not found");        

            var post = await _context.Posts
                .Include(p => p.Photos)
                .Include(p => p.License)
                .FirstOrDefaultAsync(p => p.PostId == postId && p.UserId == currentUserId);
            if (post == null)
                return Results<PostResponseDto>.NotFound("Post not found or you do not have permission to update this post.");
            
            if (!string.IsNullOrWhiteSpace(newTitle))
                post.Title = newTitle;
            if (licenseId.HasValue)
            {
                var license = await _context.Licenses.FindAsync(licenseId.Value);
                if (license == null)
                    return Results<PostResponseDto>.Bad("License not found");
                post.LicenseId = license.LicenseId;
                post.License = license;
            }
            post.UpdatedDate = DateTimeOffset.Now;

            await _context.SaveChangesAsync();

            var dto = new PostResponseDto
            {
                PostId = post.PostId,
                UserId = post.UserId,
                Title = post.Title,
                LicenseName = post.License?.Name,
                CreatedDate = post.CreatedDate,
                Photos = post.Photos.Select(p => new PostPhotoDto
                {
                    PhotoId = p.PhotoId,
                    OriginalFileUrl = p.OriginalFileUrl,
                    IsPublic = p.IsPublic
                }).ToList(),
                UpdatedDate = post.UpdatedDate
            };

            return Results<PostResponseDto>.Ok(dto," updated succesfully");
        }

        //get all post of a user 
        public async Task<Results<List<PostResponseDto>>> GetPostsByUserAsync(string userId)
        {
            var posts = await _context.Posts
                .Where(p => p.UserId == userId)
                .Include(p => p.Photos)
                .Include(p => p.License)
                .OrderByDescending(p => p.CreatedDate)
                .ToListAsync();
            if (posts == null || posts.Count == 0)
                return Results<List<PostResponseDto>>.NotFound("No posts found for the specified user.");

            var postDtos = posts.Select(post => new PostResponseDto
            {
                PostId = post.PostId,
                UserId = post.UserId,
                Title = post.Title,
                CreatedDate = post.CreatedDate,
                LicenseName = post.License?.Name,
                Photos = post.Photos
                .Where(p => p.IsPublic)
                .Select(p => new PostPhotoDto
                {
                    PhotoId = p.PhotoId,
                    OriginalFileUrl = p.OriginalFileUrl,
                    IsPublic = p.IsPublic
                }).ToList(),
                UpdatedDate = post.UpdatedDate
            }).ToList();
            return Results<List<PostResponseDto>>.Ok(postDtos);
        }
  
        //view a post by postId
        public async Task<Results<PostResponseDto>> GetPostByIdAsync(Guid postId)
        {
            var post = await _context.Posts
                .Where(p => p.PostId == postId)
                .Include(p => p.Photos)
                .Include(p => p.License)
                .FirstOrDefaultAsync();
            if (post == null)
                return Results<PostResponseDto>.NotFound("Post not found.");

            var publicPhotos = post.Photos
                .Where(p => p.IsPublic)
                .Select(p => new PostPhotoDto
                {
                    PhotoId = p.PhotoId,
                    OriginalFileUrl = p.OriginalFileUrl,
                    IsPublic = p.IsPublic
                });
            var dto = new PostResponseDto
            {
                PostId = post.PostId,
                UserId = post.UserId,
                Title = post.Title,
                LicenseName = post.License?.Name,
                CreatedDate = post.CreatedDate,
                Photos = publicPhotos.ToList(),
                UpdatedDate = post.UpdatedDate
            };
            return Results<PostResponseDto>.Ok(dto);
        }
    }
}
