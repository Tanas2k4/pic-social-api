using PicSocial.Server.DTOs.PhotosDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IPhotoService
    {
        Task<Result> UpdatePhotoAsync(Guid photoId, string currentUserId, PhotoUpdateDto dto);
    }
}
