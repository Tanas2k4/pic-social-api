using System;

namespace PicSocial.Server.Models.Entities
{
    public class PhotoVersion
    {
        public Guid PhotoVersionId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public string VersionType { get; set; } = null!; // Thumbnail, Medium, Retina, WebP, AVIF
        public string FileUrl { get; set; } = null!;
        public int FileSize { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }

        // Navigation property
        public Photo Photo { get; set; } = null!;
    }
}