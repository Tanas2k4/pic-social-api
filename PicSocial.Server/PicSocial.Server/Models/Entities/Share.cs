using PicSocial.Server.Models.Interfaces;
using System;

namespace PicSocial.Server.Models.Entities
{
    public class Share : IDateTracking
    {
        public Guid ShareId { get; set; } = Guid.NewGuid();
        public Guid PostId { get; set; }
        public string UserId { get; set; } = null!;
        public string? SharePlatform { get; set; }
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }

        // Navigation properties
        public Post Post { get; set; } = null!;
        public ApplicationUser User { get; set; } = null!;
    }
}