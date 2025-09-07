using PicSocial.Server.Models.Interfaces;
using System;
using System.Collections.Generic;

namespace PicSocial.Server.Models.Entities
{
    public class Photo : IDateTracking
    {
        public Guid PhotoId { get; set; } = Guid.NewGuid();
        public string UserId { get; set; } = null!;
        public string? Title { get; set; }
        public string? Description { get; set; }
        public DateTimeOffset CreatedDate { get; set; } 
        public DateTimeOffset? UpdatedDate { get; set; }
        public string OriginalFileUrl { get; set; } = null!;
        public bool AllowDownload { get; set; } = false;
        public int? MaxPublicResolution { get; set; }
        public bool IsPublic { get; set; } = true;
        public string Visibility { get; set; } = "Public"; // Public, Followers, Private
        public int ViewCount { get; set; } = 0;

        // Navigation properties
        public ApplicationUser User { get; set; } = null!;
        public PhotoMetadata? Metadata { get; set; }
        public PhotoLicense? License { get; set; }
        public ICollection<PhotoVersion> Versions { get; set; } = new List<PhotoVersion>();
        public ICollection<AlbumPhoto> AlbumPhotos { get; set; } = new List<AlbumPhoto>();
        public ICollection<PhotoTag> PhotoTags { get; set; } = new List<PhotoTag>();
        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public ICollection<Like> Likes { get; set; } = new List<Like>();
        public ICollection<Share> Shares { get; set; } = new List<Share>();
        public ICollection<Report> Reports { get; set; } = new List<Report>();
    }
}