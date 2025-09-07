using PicSocial.Server.Models.Interfaces;
using System.Data;

namespace PicSocial.Server.Models.Entities
{
    public class Follow : IDateTracking
    {
        public Guid FollowId { get; set; } = Guid.NewGuid();
        public string FollowerId { get; set; } = null!;
        public string FollowedId { get; set; } = null!;
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }

        // Navigation properties
        public ApplicationUser Follower { get; set; } = null!;
        public ApplicationUser Followed { get; set; } = null!;
    }
}