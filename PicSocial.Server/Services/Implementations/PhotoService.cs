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
            var photo = await _context.Photos.FirstOrDefaultAsync(p => p.PhotoId == photoId);
            if (photo == null)
                return Result.NotFound("Not found");
            if (dto.IsPublic.HasValue)
                photo.IsPublic = dto.IsPublic.Value;

            if (dto.AllowDownload.HasValue)
                photo.AllowDownload = dto.AllowDownload.Value;

            await _context.SaveChangesAsync();
            return Result.Ok("update successfully");
        }


        //View detail a photos in a photos
        public async Task<Results<PhotoDetailDto>> GetPhotoByIdAsync(string userId, Guid photoId)
        {
            var photoDtos = await _context.Photos
                .Where(p => p.PhotoId == photoId && p.UserId == userId)
                .Select(p => new PhotoDetailDto
                {
                    UserId = p.UserId,
                    PostId = p.PostId,
                    PhotoId = p.PhotoId,
                    AllowDownload = p.AllowDownload,
                    MaxPublicResolution = p.MaxPublicResolution,
                    photoMetadataDto = p.Metadata == null ? null : new PhotoMetadataDto
                    {
                        Lens = p.Metadata.Lens,
                        Aperture = p.Metadata.Aperture,
                        ShutterSpeed = p.Metadata.ShutterSpeed,
                        ISO = p.Metadata.ISO,
                        CameraModel = p.Metadata.CameraModel,
                        Location = p.Metadata.Location,
                        IPTCKeywords = p.Metadata.IPTCKeywords,
                        IPTCCaption = p.Metadata.IPTCCaption
                    },
                    photoXmpMetadataDto = p.XmpMetadata == null ? null : new PhotoXmpMetadataDto
                    {
                        RawXmp = p.XmpMetadata.RawXmp,
                        Rating = p.XmpMetadata.Rating,
                        Title = p.XmpMetadata.Title,
                        Caption = p.XmpMetadata.Caption,
                        KeywordsJson = p.XmpMetadata.KeywordsJson,
                        ColorLabel = p.XmpMetadata.ColorLabel
                    },
                    CreatedDate = p.CreatedDate,
                    UpdatedDate = p.UpdatedDate
                })
            .FirstOrDefaultAsync();
            if (photoDtos == null)
                return Results<PhotoDetailDto>.NotFound("Photo not found");

            return Results<PhotoDetailDto>.Ok(photoDtos);
        }

        //download a photo in a post


    }
}
