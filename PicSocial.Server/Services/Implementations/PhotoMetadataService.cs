using System.Text.Json;
using MetadataExtractor;
using MetadataExtractor.Formats.Exif;
using MetadataExtractor.Formats.Iptc;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Services.Implementations
{
    public class PhotoMetadataService : IPhotoMetadataService
    {
        //Extract metadata from image file
        public PhotoMetadata ExtractExifIptc(Stream stream, Guid photoId)
        {

            //Read metadata directories from the image stream
            var directories = ImageMetadataReader.ReadMetadata(stream);
            //get EXIF and IPTC directories
            var exif = directories.OfType<ExifSubIfdDirectory>().FirstOrDefault();
            var ifd0 = directories.OfType<ExifIfd0Directory>().FirstOrDefault();
            var iptc = directories.OfType<IptcDirectory>().FirstOrDefault();
            
            return new PhotoMetadata
            {
                PhotoId = photoId,

                // Ống kính (ví dụ: "Canon EF 50mm f/1.8 STM")
                Lens = exif?.GetDescription(ExifDirectoryBase.TagLensModel),

                // bug không lấy được khẩu độ ảnh
                // Khẩu độ - dùng GetDescription để được chuỗi đẹp "f/1.8", "f/2.8",...
                Aperture = exif?.GetDescription(ExifDirectoryBase.TagFNumber),
                
                // Tốc độ màn trập (ví dụ: "1/250 sec", "1/60 sec", "30 sec")
                ShutterSpeed = exif?.GetDescription(ExifDirectoryBase.TagExposureTime),

                // ISO (số nguyên: 100, 200, 6400,...)
                ISO = exif?.GetInt32(ExifDirectoryBase.TagIsoEquivalent),

                // Tên máy ảnh (ví dụ: "Canon EOS 5D Mark IV")
                CameraModel = ifd0?.GetDescription(ExifDirectoryBase.TagModel),

                // Vị trí chụp ảnh (lấy từ IPTC nếu có)
                Location = iptc?.GetDescription(IptcDirectory.TagSubLocation),

                // Chú thích từ IPTC
                IPTCCaption = iptc?.GetDescription(IptcDirectory.TagCaption),

                // Từ khóa IPTC dạng JSON
                IPTCKeywords = iptc != null
                    ? JsonSerializer.Serialize(iptc.GetKeywords())
                    : null
            };
        }
    }
}