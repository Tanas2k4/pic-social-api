using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs.PhotosDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Implementations
{
    public class PhotoService : IPhotoService
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        public PhotoService(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        //update a photo in a post
        public async Task<Result> UpdatePhotoAsync(Guid photoId, string currentUserId, PhotoUpdateDto dto)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Result.Unauthorized("User not found");
            
            var photo = await _context.Photos.FirstOrDefaultAsync(p =>  p.PhotoId == photoId);
            if (photo == null)
                return Result.NotFound("Not found");
                
            if (dto.IsPublic.HasValue)
                photo.IsPublic = dto.IsPublic.Value;

            if (dto.AllowDownload.HasValue) 
                photo.AllowDownload = dto.AllowDownload.Value;

            await _context.SaveChangesAsync();
            return Result.Ok("update successfully");
        }


        //View detail all photos in a post


        //dowload a photo in a post


    }
}
