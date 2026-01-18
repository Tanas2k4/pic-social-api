using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IPhotoXmpMetadataService
    {
        //implement method to extract XMP metadata from image file
        PhotoXmpMetadata? ExtractXmp(Stream stream);
    }
}