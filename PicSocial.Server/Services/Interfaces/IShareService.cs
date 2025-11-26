using PicSocial.Server.DTOs.SharesDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IShareService
    {
        Task<Results<ShareCreateDto>> SharePostAsync(Guid postId, string userId, ShareDto shareDto);
        Task<Result> DeleteSharePostAsync(Guid postId, Guid shareId, string currenUserId);
    }
}
