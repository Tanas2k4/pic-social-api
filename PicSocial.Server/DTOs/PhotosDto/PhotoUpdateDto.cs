namespace PicSocial.Server.DTOs.PhotosDto
{
    public class PhotoUpdateDto
    {
        public bool? IsPublic { get; set; } 
        public bool? AllowDownload {  get; set; }
    }
}
