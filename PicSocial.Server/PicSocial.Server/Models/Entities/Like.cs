using PicSocial.Server.Models.Interfaces;
using System;

namespace PicSocial.Server.Models.Entities
{
    public class Like : IDateTracking
    {
        public Guid LikeId { get; set; } = Guid.NewGuid();
        // public Guid PhotoId { get; set; }
        public Guid PostId { get; set; }
        public string UserId { get; set; } = null!;
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }
        // public int CountLike { get; set; } = 0;

        // Navigation properties
        public Post Post { get; set; } = null!;
        public ApplicationUser User { get; set; } = null!;
    }
}