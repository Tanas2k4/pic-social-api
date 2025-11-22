using Microsoft.AspNetCore.Mvc;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IAdminService
    {
        Task<IActionResult> GetAllUserAsync();
        Task<bool> DeleteUserAsync(string targetUserId, string currentUserId);
        Task<IActionResult> GetAllReportsAsync();
        Task<IActionResult> GetReportByIdAsync(Guid postId);
        Task<IActionResult> TotalPostAsync();
    }
}
