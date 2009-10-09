#import "fonts.h"

FT_Library ft_library;
static int initialized = 0;
NSMutableDictionary *fonts;

struct font_texture_buffer {
	uint8_t *data;
	int square_size, cursor_x, cursor_y, row_height;
};

#define GLYPH_METRICS_TO_FLOAT(a) (((float) a) / 64.0f)
#define AVERAGE_CHARACTER_SIZE 0.7f

static int activate(FontRendition *font);
static int loadCharacter(FontRendition *font, struct font_texture_buffer *buffer,
	int32_t codepoint);


@implementation Font : NSObject
+ (int) initFonts {
	bzero(&ft_library, sizeof(FT_Library));
	FT_Error result = FT_Init_FreeType(&ft_library);
	if(result) {
		fprintf(stderr, "FT_Init_FreeType(): %i\n", result);
		return 1;
	}
	fonts = [NSMutableDictionary dictionaryWithCapacity: 16];
	return 0;
}


+ (Font *) font: (NSString *) name {
	return [fonts objectForKey: name];
}


+ (FontRendition *) fontRendition: (NSString *) name forSize: (unsigned int) size {
	Font *font = [self font: name];
	if(!font) return nil;
	return [font renditionForSize: size];
}


+ (Font *) load: (NSString *) filename {
	return [[self alloc] load: filename];
}


- (Font *) load: (NSString *) filename {	
	bzero(&ftFace, sizeof(ftFace));
	FT_Error error = FT_New_Face(ft_library, [filename UTF8String], 0, &ftFace);
	if(error) {
		fprintf(stderr, "FT_New_Face(\"%s\"): %i\n", [filename UTF8String], error);
		return nil;
	}
	
	renditions = [NSMutableArray arrayWithCapacity: 1];
	
	NSString *name = [NSString stringWithCString: FT_Get_Postscript_Name(ftFace)
						encoding: NSASCIIStringEncoding];
	[fonts setObject: self forKey: name];
	
	return self;
}


- (FontRendition *) renditionForSize: (unsigned int) size {
	NSEnumerator *enumerator = [renditions objectEnumerator];
	
	FontRendition *rendition;
	while(rendition = [enumerator nextObject]) {
		if([rendition size] == size)
			return rendition;
	}
	
	return [self renderSize: size];
}


- (FontRendition *) renderSize: (unsigned int) size {
	FontRendition *rendition = [[FontRendition alloc] renderFont: self size: size];
	[renditions addObject: rendition];
	return rendition;
}


- (FT_Face) FTFace {
	return ftFace;
}
@end


@implementation FontRendition : NSObject
- (unsigned int) size {
	return pointSize;
}


- (FontRendition *) renderFont: (Font *) newFont size: (unsigned int) newSize {	
	font = newFont;
	pointSize = newSize;
	metrics = [NSMutableDictionary dictionaryWithCapacity: 128];
	
	if(!activate(self))
		return nil;
	
	int n_chars = 120;
	int square_size = pointSize * AVERAGE_CHARACTER_SIZE * sqrtf(n_chars);
	square_size = exp2f(ceilf(log2f(square_size)));
	
	struct font_texture_buffer buffer;
	buffer.data = malloc(square_size*square_size);
	bzero(buffer.data, square_size*square_size);
	
	buffer.square_size = square_size;
	buffer.cursor_x = 0;
	buffer.cursor_y = 0;
	buffer.row_height = 0;
	
	int32_t codepoint;
	for(codepoint = ' '; codepoint < 127; codepoint++) {
		int temp = loadCharacter(self, &buffer, codepoint);
		if(temp == 2) break;
	}
		
	glGenTextures(1, &textureID);
	glBindTexture(GL_TEXTURE_2D, textureID);
	
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_IMAGE_HEIGHT, 0);
	glPixelStorei(GL_UNPACK_SWAP_BYTES, GL_FALSE);
	
	glTexImage2D(GL_TEXTURE_2D,
					0,
					GL_ALPHA,
					square_size, square_size,
					0,
					GL_ALPHA,
					GL_UNSIGNED_BYTE,
					buffer.data);
	
	float values[4] = { 1.0f, 1.0f, 1.0f, 0.0f };
	
	glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR,
		   (GLfloat *) &values);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glBindTexture(GL_TEXTURE_2D, 0);
	
	return self;
}


static int loadCharacter(FontRendition *rendition, struct font_texture_buffer *buffer,
		int32_t codepoint) {
	FT_Face ftFace = [rendition FTFace];
	
	FT_Error error = FT_Load_Char(ftFace, codepoint, FT_LOAD_DEFAULT);
	if(error) {
		fprintf(stderr, "FT_Load_Char(): %i\n", error);
		return 1;
	}
	
	error = FT_Render_Glyph(ftFace->glyph, FT_RENDER_MODE_NORMAL);
	if(error) {
		fprintf(stderr, "FT_Render_Glyph(): %i\n", error);
		return 1;
	}
	FT_Bitmap *ft_bitmap = &ftFace->glyph->bitmap;
	
	if(buffer->cursor_x + ft_bitmap->width > buffer->square_size) {
		if((buffer->cursor_y + buffer->row_height + ft_bitmap->rows > buffer->square_size)
			|| (ft_bitmap->width > buffer->square_size)) {
			fprintf(stderr, "The font %s doesn't fit in its texture of size %ix%i.\n",
				FT_Get_Postscript_Name(ftFace),
				buffer->square_size,
				buffer->square_size);
			return 2;
		}
		buffer->cursor_y += buffer->row_height + 1;
		buffer->cursor_x = 0;
		buffer->row_height = 0;
	}
	
	FontTextureMetrics *metrics = [rendition metricsForCodepoint: codepoint];
	int left = buffer->cursor_x;
	int right = left + ft_bitmap->width;
	int top = buffer->cursor_y;
	int bottom = top + ft_bitmap->rows;
	metrics->texLeft = ((float) left) / ((float) buffer->square_size);
	metrics->texRight = ((float) right) / ((float) buffer->square_size);
	metrics->texTop = ((float) top) / ((float) buffer->square_size);
	metrics->texBottom = ((float) bottom) / ((float) buffer->square_size);
	
	uint8_t *displaced_buffer = buffer->data + buffer->cursor_x
		+ buffer->square_size*buffer->cursor_y;
	int x, y;
	for(y = 0; y < ft_bitmap->rows; y++)
		for(x = 0; x < ft_bitmap->width; x++)
			displaced_buffer[x + buffer->square_size*y]
				= ft_bitmap->buffer[x + ft_bitmap->pitch*y];
	
	buffer->cursor_x += ft_bitmap->width + 1;
	if(buffer->row_height < ft_bitmap->rows) buffer->row_height = ft_bitmap->rows;
	
	return 0;
}


- (TextLayout *) layoutString: (NSString *) text anchor: (int) anchor align: (int) align {
	TextLayout *layout = [TextLayout alloc];
	[layout initWithFontRendition: self anchor: anchor align: align];
	[layout addString: text];
	return layout;
}


- (void) drawString: (NSString *) text anchor: (int) anchor align: (int) align {
	TextLayout *layout = [self layoutString: text anchor: anchor align: align];
	[layout draw: text];
	[layout release];
}


- (FT_Face) FTFace {
	return [font FTFace];
}


- (float) baselineSeparation {
	return GLYPH_METRICS_TO_FLOAT([self FTFace]->size->metrics.height);
}


- (float) ascent {
	return GLYPH_METRICS_TO_FLOAT([self FTFace]->size->metrics.ascender);
}


- (float) descent {
	return -GLYPH_METRICS_TO_FLOAT([self FTFace]->size->metrics.descender);
}


- (GLuint) textureID {
	return textureID;
}


- (FontTextureMetrics *) metricsForCodepoint: (uint32_t) codepoint {
	NSNumber *key = [NSNumber numberWithUnsignedLong: codepoint];
	FontTextureMetrics *result = [metrics objectForKey: key];
	if(result) return result;
	result = [FontTextureMetrics alloc];
	[metrics setObject: result forKey: key];
	return result;
}
@end


@implementation FontTextureMetrics : NSObject
@end


@implementation TextLayout : NSObject
- (TextLayout *) initWithFontRendition: (FontRendition *) newRendition
		anchor: (int) newAnchor align: (int) newAlign {
	rendition = [newRendition retain];
	anchor = newAnchor;
	align = newAlign;
	boundingBox = [[Rectangle alloc] initWithTop: 0 left: 0 width: 0 height: 0];
	allRows = [[NSMutableArray alloc] initWithCapacity: 4];
	return self;
}


- (void) dealloc {
	[rendition release];
	[boundingBox release];
	[allRows release];
	[super dealloc];
}


- (void) addString: (NSString *) string {
	FT_Face ftFace = [rendition FTFace];
	
	if(!activate(rendition))
		return;
	
	TextLayoutRow *currentRow
		= [[[TextLayoutRow alloc] initWithFontRendition: rendition align: align] autorelease];
	
	int32_t last_codepoint = -1;
	unsigned int length = [string length];
	unsigned int i;
	for(i = 0; i < length; i++) {
		int32_t codepoint = [string characterAtIndex: i];
		
		if(codepoint == '\n') {
			TextLayoutRow *nextRow = [TextLayoutRow alloc];
			[nextRow initWithFontRendition: rendition align: align];
			[nextRow autorelease];
			
			[currentRow fixBaselineSeparation];
			[self addRow: currentRow];
			[nextRow fixTopBelowRow: currentRow];
			currentRow = nextRow;
			continue;
		}
		
		FT_Load_Char(ftFace, codepoint, FT_LOAD_DEFAULT);
		FT_Glyph_Metrics *glyph_metrics = &ftFace->glyph->metrics;
		
		float ascent = GLYPH_METRICS_TO_FLOAT(glyph_metrics->horiBearingY);
		float descent = GLYPH_METRICS_TO_FLOAT(glyph_metrics->height) - ascent;
		[currentRow setMinimumAscent: ascent];
		[currentRow setMinimumDescent: descent];
		
		if(last_codepoint != -1) {
			FT_Vector kerning;
			FT_Get_Kerning(ftFace,
				FT_Get_Char_Index(ftFace, last_codepoint),
				FT_Get_Char_Index(ftFace, codepoint),
				FT_KERNING_DEFAULT, &kerning);
			float kerningOffset = GLYPH_METRICS_TO_FLOAT(kerning.x);
			[currentRow increaseWidth: kerningOffset];
		}
		last_codepoint = codepoint;
		
		Rectangle *quad
			= [[Rectangle alloc] initWithTop: -GLYPH_METRICS_TO_FLOAT(glyph_metrics->horiBearingY)
				left: [currentRow width] + GLYPH_METRICS_TO_FLOAT(glyph_metrics->horiBearingX)
				width: GLYPH_METRICS_TO_FLOAT(glyph_metrics->width)
				height: GLYPH_METRICS_TO_FLOAT(glyph_metrics->height)];
		[currentRow addQuad: [quad autorelease]];

		[currentRow increaseWidth: GLYPH_METRICS_TO_FLOAT(glyph_metrics->horiAdvance)];
	}
	[currentRow fixBaselineSeparation];
	[self addRow: currentRow];
	
	[self fixAnchor];
}

- (void) addRow: (TextLayoutRow *) row {
	[allRows addObject: row];
	if([boundingBox width] < [row width])
		[boundingBox setWidth: [row width]];
	[boundingBox setHeight: [boundingBox height] + [row height]];
}


- (void) draw: (NSString *) text {
	glBindTexture(GL_TEXTURE_2D, [rendition textureID]);
	glBegin(GL_QUADS);	
	
	NSEnumerator *rowEnumerator = [self rowEnumerator];
	TextLayoutRow *currentRow = [rowEnumerator nextObject];
	NSEnumerator *quadEnumerator = [currentRow quadEnumerator];
	float baseline = [boundingBox top] + [currentRow baseline];
	
	unsigned int length = [text length];
	unsigned int i;
	for(i = 0; i < length; i++) {
		int32_t codepoint = [text characterAtIndex: i];
		
		if(codepoint == '\n') {
			currentRow = [rowEnumerator nextObject];
			quadEnumerator = [currentRow quadEnumerator];
			baseline = [boundingBox top] + [currentRow baseline];
			continue;
		}
		
		FontTextureMetrics *texMetrics = [rendition metricsForCodepoint: codepoint];
		
		Rectangle *quad = [quadEnumerator nextObject];
		float quad_left = [currentRow left] + [quad left];
		float quad_right = [currentRow left] + [quad right];
		float quad_top = baseline + [quad top];
		float quad_bottom = baseline + [quad bottom];
		
		glTexCoord2f(texMetrics->texLeft, texMetrics->texTop);
		glVertex2f(quad_left, quad_top);
		glTexCoord2f(texMetrics->texRight, texMetrics->texTop);
		glVertex2f(quad_right, quad_top);
		glTexCoord2f(texMetrics->texRight, texMetrics->texBottom);
		glVertex2f(quad_right, quad_bottom);
		glTexCoord2f(texMetrics->texLeft, texMetrics->texBottom);
		glVertex2f(quad_left, quad_bottom);
	}
	
	glEnd();
	glBindTexture(GL_TEXTURE_2D, 0);
}


- (NSEnumerator *) rowEnumerator {
	return [allRows objectEnumerator];
}


- (Rectangle *) boundingBox {
	return boundingBox;
}


- (void) fixAnchor {
	[boundingBox setAnchor: anchor];
	
	NSEnumerator *rowEnumerator = [self rowEnumerator];
	TextLayoutRow *row;
	while(row = [rowEnumerator nextObject]) {
		[row fixAlignment: boundingBox];
	}
}
@end


@implementation TextLayoutRow : NSObject
- (TextLayoutRow *) initWithFontRendition: (FontRendition *) rendition align: (int) newAlign {
	top = 0;
	left = 0;
	width = 0;
	ascent = [rendition ascent];
	descent = [rendition descent];
	height = [rendition baselineSeparation];
	align = newAlign;
	quads = [[NSMutableArray arrayWithCapacity: 16] retain];
	return self;
}


- (void) dealloc {
	[quads release];
	[super dealloc];
}


- (void) fixBaselineSeparation {
	float minimumBaselineSeparation = ascent + descent;
	if(height < minimumBaselineSeparation)
		height = minimumBaselineSeparation;
}


- (void) fixTopBelowRow: (TextLayoutRow *) priorRow {
	top = [priorRow bottom];
}


- (void) fixAlignment: (Rectangle *) boundingBox {
	switch(align) {
	case LEFT:
		left = [boundingBox left];
		break;
	case CENTER:
		left = ([boundingBox left] + [boundingBox right] - width) / 2.0f;
		break;
	case RIGHT:
		left = [boundingBox right] - width;
		break;
	}
}


- (void) setMinimumAscent: (float) newAscent {
	if(ascent < newAscent) ascent = newAscent;
}


- (void) setMinimumDescent: (float) newDescent {
	if(descent < newDescent) descent = newDescent;
}


- (void) increaseWidth: (float) widthIncrement {
	width += widthIncrement;
}


- (void) addQuad: (Rectangle *) quad {
	[quads addObject: quad];
}


- (NSEnumerator *) quadEnumerator {
	return [quads objectEnumerator];
}


- (float) width {
	return width;
}


- (float) height {
	return height;
}


- (float) top {
	return top;
}


- (float) bottom {
	return top + height;
}


- (float) left {
	return left;
}


- (float) ascent {
	return ascent;
}

- (float) descent {
	return descent;
}

- (float) baseline {
	return top + ascent;
}
@end


static int activate(FontRendition *rendition) {
	FT_Face ftFace = [rendition FTFace];
	unsigned int pointSize = [rendition size];
	FT_Error error = FT_Set_Pixel_Sizes(ftFace, pointSize, pointSize);
	if(error) {
		fprintf(stderr, "FT_Set_Pixel_Sizes(): %i\n", error);
		return 0;
	}
	return 1;	
}
