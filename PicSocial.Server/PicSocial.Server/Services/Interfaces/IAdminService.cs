using Microsoft.AspNetCore.Mvc;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IAdminService
    {
        Task<IActionResult> GetAllUserAsync();
        Task<IActionResult> DeleteUserAsync(string targetUserId);
        Task<IActionResult> GetAllReportsAsync();
        Task<IActionResult> GetReportByIdAsync(Guid postId);
        Task<IActionResult> TotalPostAsync();
    }
}
