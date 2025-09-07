using PicSocial.Server.Models.Interfaces;
using System;
using System.Collections.Generic;

namespace PicSocial.Server.Models.Entities
{
    public class Album : IDateTracking
    {
        public Guid AlbumId { get; set; } = Guid.NewGuid();
        public string UserId { get; set; } = null!;
        public string? Name { get; set; } 
        public string? Description { get; set; }
        public string? Theme { get; set; }
        public bool IsPublic { get; set; } = true;
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }

        // Navigation properties
        public ApplicationUser User { get; set; } = null!;
        public ICollection<AlbumPhoto> AlbumPhotos { get; set; } = new List<AlbumPhoto>();
    }
}