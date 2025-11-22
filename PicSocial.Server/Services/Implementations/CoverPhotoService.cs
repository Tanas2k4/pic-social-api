using Microsoft.AspNetCore.Identity;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Implementations
{
    public class CoverPhotoService : ICoverPhotoService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly GoogleCloudStorageService _googleCloudStorageService;
        
        public CoverPhotoService(UserManager<ApplicationUser> userManager, GoogleCloudStorageService googleCloudStorageService)
        {
            _userManager = userManager;
            _googleCloudStorageService = googleCloudStorageService;
        }

        //upload cover photo
        public async Task<Result> UploadPhotoCoverAsync(string currentUserId, IFormFile photoCover)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null) {
                return Result.Unauthorized("User not found");
            }
            //Kiểm tra file
            if (photoCover == null)
            {
                return Result.Bad("not found");
            }
            //ghì đè nếu có ảnh bìa cũ 
            if (!string.IsNullOrEmpty(currentUser.CoverPhotoUrl))
            {
                var oldCoverPhoto = Path.GetFileName(currentUser.CoverPhotoUrl);
                await _googleCloudStorageService.DeleteFileAsync($"coverPhotos/{oldCoverPhoto}");
            }
            var objectName = $"coverPhotos/{Guid.NewGuid()}{Path.GetExtension(photoCover.FileName)}";
            var fileUrl = await _googleCloudStorageService.UploadFileAsync(
                photoCover.OpenReadStream(),
                objectName,
                photoCover.ContentType
            );

            currentUser.CoverPhotoUrl = fileUrl;
            await _userManager.UpdateAsync(currentUser);

            return Result.Ok("cover photo uploaded");
        }

        //delete cover photo
        public async Task<Result> DeletePhotoCoverAsync(string currentUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)            
                return Result.Unauthorized("User not found");
            
            if (string.IsNullOrEmpty(currentUser.CoverPhotoUrl))          
                return Result.Bad("No cover photo to delete");
            
            var objectName = Path.GetFileName(currentUser.CoverPhotoUrl);
            await _googleCloudStorageService.DeleteFileAsync($"coverPhotos/{objectName}");
            currentUser.CoverPhotoUrl = null;
            await _userManager.UpdateAsync(currentUser);
            return Result.Ok("Cover photo deleted successfully");
        }
    }
}
