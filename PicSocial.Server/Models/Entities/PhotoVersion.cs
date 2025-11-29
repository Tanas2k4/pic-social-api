using System;

namespace PicSocial.Server.Models.Entities
{
    public class PhotoVersion
    {
        public Guid PhotoVersionId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public string VersionType { get; set; } = null!; // Thumbnail(200px), Medium(1080), Retina(2x), WebP, AVIF, RAW
        public string FileUrl { get; set; } = null!; // Đường dẫn tới file ảnh phiên bản này
        public int FileSize { get; set; } // Kích thước file tính bằng KB
        public int Width { get; set; } 
        public int Height { get; set; }

        // Navigation property
        public Photo Photo { get; set; } = null!;
    }
}