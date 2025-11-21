using PicSocial.Server.DTOs;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IShareService
    {
        Task<Result<ShareResponseDto>> SharePostAsync(Guid postId, string userId, ShareDto shareDto);
        Task<Result> DeleteSharePostAsync(Guid postId, Guid shareId, string currenUserId);
    }
}
