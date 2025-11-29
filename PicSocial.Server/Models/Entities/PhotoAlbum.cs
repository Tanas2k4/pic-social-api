using System;

namespace PicSocial.Server.Models.Entities
{
    public class AlbumPhoto
    {
        public Guid AlbumId { get; set; }
        public Guid PhotoId { get; set; }
        public int Order { get; set; } = 0; //Sắp xếp thứ tự ảnh trong album

        // Navigation properties
        public Album Album { get; set; } = null!;
        public Photo Photo { get; set; } = null!;
    }
}