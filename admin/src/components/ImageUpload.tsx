import { useRef, useState } from 'react';
import { Upload, Image as ImageIcon } from 'lucide-react';

interface Props {
  currentUrl?: string | null;
  onUpload: (file: File) => void;
  isUploading?: boolean;
}

const ALLOWED = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
const MAX_MB = 5;

export default function ImageUpload({ currentUrl, onUpload, isUploading }: Props) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleFile = (file: File) => {
    setError(null);
    if (!ALLOWED.includes(file.type)) { setError('Only JPEG, PNG, WEBP allowed'); return; }
    if (file.size > MAX_MB * 1024 * 1024) { setError(`File must be under ${MAX_MB}MB`); return; }
    const reader = new FileReader();
    reader.onload = (e) => setPreview(e.target?.result as string);
    reader.readAsDataURL(file);
    onUpload(file);
  };

  const displaySrc = preview ?? currentUrl;

  return (
    <div className="space-y-2">
      {displaySrc ? (
        <div className="relative w-32 h-32 rounded-lg overflow-hidden border border-gray-200">
          <img src={displaySrc} alt="Preview" className="w-full h-full object-cover" />
          {isUploading && (
            <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
              <div className="w-6 h-6 border-2 border-white border-t-transparent rounded-full animate-spin" />
            </div>
          )}
        </div>
      ) : (
        <div className="w-32 h-32 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center">
          <ImageIcon size={32} className="text-gray-400" />
        </div>
      )}
      <button type="button" onClick={() => inputRef.current?.click()}
        disabled={isUploading}
        className="flex items-center gap-2 px-3 py-1.5 text-sm border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50">
        <Upload size={14} />
        {isUploading ? 'Uploading…' : displaySrc ? 'Change Image' : 'Upload Image'}
      </button>
      {error && <p className="text-xs text-red-600">{error}</p>}
      <input ref={inputRef} type="file" accept="image/jpeg,image/png,image/webp"
        className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) handleFile(f); }} />
    </div>
  );
}
