using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Implementations
{
    public class ReportService: IReportService
    {
        private readonly ApplicationDbContext _context;
        public ReportService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Result> ReportPostAsync(Guid postId, string userId, string reason)
        {
            var post = await _context.Posts.FindAsync(postId);
            if (post == null)
                return Result.NotFound("Post not found");
            var report = new Report
            {
                PostId = postId,
                UserId = userId,
                Reason = reason,
                CreatedDate = DateTimeOffset.Now,
                Status = "Pending"
            };
            _context.Reports.Add(report);
            await _context.SaveChangesAsync();
            return Result.Ok("report sent");
        }
    }
}
