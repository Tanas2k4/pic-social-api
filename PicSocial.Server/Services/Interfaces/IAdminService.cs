using PicSocial.Server.DTOs.AdminDto;
using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IAdminService
    {
        Task<List<UserSummaryDto>> GetAllUserAsync();
        Task<bool> DeleteUserAsync(string targetUserId, string currentUserId);
        Task<List<Report>> GetAllReportsAsync();
        Task<List<Report>> GetReportByIdAsync(Guid postId);
        Task<int> TotalPostAsync();
    }
}
