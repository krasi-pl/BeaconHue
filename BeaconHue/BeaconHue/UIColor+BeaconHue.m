//
//  UIColor+BeaconHue.m
//  BeaconHue
//
//  Created by Karol Kozimor on 30/11/13.
//  Copyright (c) 2013 Appuccino. All rights reserved.
//

#import "UIColor+BeaconHue.h"

@implementation UIColor (BeaconHue)

enum {
    cptRED = 0,
    cptBLUE,
    cptGREEN,
};

#pragma mark - Public

- (BOOL)getX:(CGFloat *)x Y:(CGFloat *)y brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
{
    return [self getX:x Y:y brightness:brightness alpha:alpha forModel:@"LCT001"];
}

- (BOOL)getX:(CGFloat *)x Y:(CGFloat *)y brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha forModel:(NSString *)model
{
    CGPoint xy;
    [UIColor calculateXY:&xy andBrightness:brightness fromColor:self forModel:model];
    *x = xy.x;
    *y = xy.y;
    *alpha = 1.0f;
    return YES;
}

#pragma mark - Internal

+ (void)calculateXY:(CGPoint *)xy andBrightness:(float *)brightness fromColor:(UIColor *)color forModel:(NSString*)model {
    CGColorRef cgColor = [color CGColor];
    
    const CGFloat *components = CGColorGetComponents(cgColor);
    int numberOfComponents = CGColorGetNumberOfComponents(cgColor);
    
    // Default to white
    CGFloat red = 1.0f;
    CGFloat green = 1.0f;
    CGFloat blue = 1.0f;
    
    if (numberOfComponents == 4) {
        // Full color
        red = components[0];
        green = components[1];
        blue = components[2];
    }
    else if (numberOfComponents == 2) {
        // Greyscale color
        red = green = blue = components[0];
    }
    
    float r = (red   > 0.04045f) ? pow((red   + 0.055f) / (1.0f + 0.055f), 2.4f) : (red   / 12.92f);
    float g = (green > 0.04045f) ? pow((green + 0.055f) / (1.0f + 0.055f), 2.4f) : (green / 12.92f);
    float b = (blue  > 0.04045f) ? pow((blue  + 0.055f) / (1.0f + 0.055f), 2.4f) : (blue  / 12.92f);
    
    float X = r * 0.4124f + g * 0.3576f + b * 0.1805f;
    float Y = r * 0.2126f + g * 0.7152f + b * 0.0722f;
    float Z = r * 0.0193f + g * 0.1192f + b * 0.9505f;
    
    float cx = X / (X + Y + Z);
    float cy = Y / (X + Y + Z);
    
    if (isnan(cx)) {
        cx = 0.0f;
    }
    
    if (isnan(cy)) {
        cy = 0.0f;
    }
    
    //Check if the given XY value is within the colourreach of our lamps.
    CGPoint xyPoint =  CGPointMake(cx,cy);
    NSArray *colorPoints = [self colorPointsForModel:model];
    BOOL inReachOfLamps = [self checkPointInLampsReach:xyPoint withColorPoints:colorPoints];
    
    if (!inReachOfLamps) {
        //It seems the colour is out of reach
        //let's find the closest colour we can produce with our lamp and send this XY value out.
        
        //Find the closest point on each line in the triangle.
        CGPoint pAB =[self getClosestPointToPoints:[[colorPoints objectAtIndex:cptRED] CGPointValue] point2:[[colorPoints objectAtIndex:cptGREEN] CGPointValue] point3:xyPoint];
        CGPoint pAC = [self getClosestPointToPoints:[[colorPoints objectAtIndex:cptBLUE] CGPointValue] point2:[[colorPoints objectAtIndex:cptRED] CGPointValue] point3:xyPoint];
        CGPoint pBC = [self getClosestPointToPoints:[[colorPoints objectAtIndex:cptGREEN] CGPointValue] point2:[[colorPoints objectAtIndex:cptBLUE] CGPointValue] point3:xyPoint];
        
        //Get the distances per point and see which point is closer to our Point.
        float dAB = [self getDistanceBetweenTwoPoints:xyPoint point2:pAB];
        float dAC = [self getDistanceBetweenTwoPoints:xyPoint point2:pAC];
        float dBC = [self getDistanceBetweenTwoPoints:xyPoint point2:pBC];
        
        float lowest = dAB;
        CGPoint closestPoint = pAB;
        
        if (dAC < lowest) {
            lowest = dAC;
            closestPoint = pAC;
        }
        if (dBC < lowest) {
            lowest = dBC;
            closestPoint = pBC;
        }
        
        //Change the xy value to a value which is within the reach of the lamp.
        cx = closestPoint.x;
        cy = closestPoint.y;
    }
    
    *xy = CGPointMake(cx, cy);
    *brightness = Y;
}

+ (UIColor *)colorFromXY:(CGPoint)xy andBrightness:(float)brightness forModel:(NSString*)model {
    
    NSArray *colorPoints = [self colorPointsForModel:model];
    BOOL inReachOfLamps = [self checkPointInLampsReach:xy withColorPoints:colorPoints];
    
    if (!inReachOfLamps) {
        //It seems the colour is out of reach
        //let's find the closest colour we can produce with our lamp and send this XY value out.
        
        //Find the closest point on each line in the triangle.
        CGPoint pAB =[self getClosestPointToPoints:[[colorPoints objectAtIndex:cptRED] CGPointValue] point2:[[colorPoints objectAtIndex:cptGREEN] CGPointValue] point3:xy];
        CGPoint pAC = [self getClosestPointToPoints:[[colorPoints objectAtIndex:cptBLUE] CGPointValue] point2:[[colorPoints objectAtIndex:cptRED] CGPointValue] point3:xy];
        CGPoint pBC = [self getClosestPointToPoints:[[colorPoints objectAtIndex:cptGREEN] CGPointValue] point2:[[colorPoints objectAtIndex:cptBLUE] CGPointValue] point3:xy];
        
        //Get the distances per point and see which point is closer to our Point.
        float dAB = [self getDistanceBetweenTwoPoints:xy point2:pAB];
        float dAC = [self getDistanceBetweenTwoPoints:xy point2:pAC];
        float dBC = [self getDistanceBetweenTwoPoints:xy point2:pBC];
        
        float lowest = dAB;
        CGPoint closestPoint = pAB;
        
        if (dAC < lowest) {
            lowest = dAC;
            closestPoint = pAC;
        }
        if (dBC < lowest) {
            lowest = dBC;
            closestPoint = pBC;
        }
        
        //Change the xy value to a value which is within the reach of the lamp.
        xy.x = closestPoint.x;
        xy.y = closestPoint.y;
    }
    
    float x = xy.x;
    float y = xy.y;
    float z = 1.0f - x - y;
    
    float Y = brightness;
    float X = (Y / y) * x;
    float Z = (Y / y) * z;
    
    float r = X  * 3.2410f - Y * 1.5374f - Z * 0.4986f;
    float g = -X * 0.9692f + Y * 1.8760f + Z * 0.0416f;
    float b = X  * 0.0556f - Y * 0.2040f + Z * 1.0570f;
    
    r = r <= 0.0031308f ? 12.92f * r : (1.0f + 0.055f) * pow(r, (1.0f / 2.4f)) - 0.055f;
    g = g <= 0.0031308f ? 12.92f * g : (1.0f + 0.055f) * pow(g, (1.0f / 2.4f)) - 0.055f;
    b = b <= 0.0031308f ? 12.92f * b : (1.0f + 0.055f) * pow(b, (1.0f / 2.4f)) - 0.055f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
}

+ (NSArray*)colorPointsForModel:(NSString*)model {
    
    // LLC001, // LedStrip
    // LWB001, // LivingWhite
    NSMutableArray *colorPoints = [NSMutableArray array];
    
    if ([model isEqualToString:@"LCT001"]) // Hue bulb 2012
    {
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.675F, 0.322F)]];     // Red
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.4091F, 0.518F)]];    // Green
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.167F, 0.04F)]];      // Blue
        
    }
    else if ([model isEqualToString:@"LLC006"] /*Bol*/ || [model isEqualToString:@"LLC007"] /*Aura*/) // Living color lights
    {
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.704F, 0.296F)]];     // Red
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.2151F, 0.7106F)]];   // Green
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.138F, 0.08F)]];      // Blue
    }
    else
    {
        // Default construct triangle wich contains all values
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(1.0F, 0.0F)]];         // Red
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.0F, 1.0F)]];         // Green
        [colorPoints addObject:[NSValue valueWithCGPoint:CGPointMake(0.0F, 0.0F)]];         // Blue
    }
    return colorPoints;
}

/**
 * Calculates crossProduct of two 2D vectors / points.
 *
 * @param p1 first point used as vector
 * @param p2 second point used as vector
 * @return crossProduct of vectors
 */
+ (float)crossProduct:(CGPoint)p1 point2:(CGPoint)p2 {
    return (p1.x * p2.y - p1.y * p2.x);
}

/**
 * Find the closest point on a line.
 * This point will be within reach of the lamp.
 *
 * @param A the point where the line starts
 * @param B the point where the line ends
 * @param P the point which is close to a line.
 * @return the point which is on the line.
 */
+ (CGPoint)getClosestPointToPoints:(CGPoint)A point2:(CGPoint)B point3:(CGPoint)P {
    CGPoint AP = CGPointMake(P.x - A.x, P.y - A.y);
    CGPoint AB = CGPointMake(B.x - A.x, B.y - A.y);
    float ab2 = AB.x*AB.x + AB.y*AB.y;
    float ap_ab = AP.x*AB.x + AP.y*AB.y;
    
    float t = ap_ab / ab2;
    
    if (t < 0.0f)
        t = 0.0f;
    else if (t > 1.0f)
        t = 1.0f;
    
    CGPoint newPoint = CGPointMake(A.x + AB.x * t, A.y + AB.y * t);
    return newPoint;
}

/**
 * Find the distance between two points.
 *
 * @param one
 * @param two
 * @return the distance between point one and two
 */
+ (float)getDistanceBetweenTwoPoints:(CGPoint)one point2:(CGPoint)two {
    float dx = one.x - two.x; // horizontal difference
    float dy = one.y - two.y; // vertical difference
    float dist = sqrt(dx * dx + dy * dy);
    
    return dist;
}

/**
 * Method to see if the given XY value is within the reach of the lamps.
 *
 * @param p the point containing the X,Y value
 * @return true if within reach, false otherwise.
 */
+ (BOOL)checkPointInLampsReach:(CGPoint)p withColorPoints:(NSArray*)colorPoints {
    
    CGPoint red =   [[colorPoints objectAtIndex:cptRED] CGPointValue];
    CGPoint green = [[colorPoints objectAtIndex:cptGREEN] CGPointValue];
    CGPoint blue =  [[colorPoints objectAtIndex:cptBLUE] CGPointValue];
    
    CGPoint v1 = CGPointMake(green.x - red.x, green.y - red.y);
    CGPoint v2 = CGPointMake(blue.x - red.x, blue.y - red.y);
    
    CGPoint q = CGPointMake(p.x - red.x, p.y - red.y);
    
    float s = [self crossProduct:q point2:v2] / [self crossProduct:v1 point2:v2];
    float t = [self crossProduct:v1 point2:q] / [self crossProduct:v1 point2:v2];
    
    if ( (s >= 0.0f) && (t >= 0.0f) && (s + t <= 1.0f))
    {
        return true;
    }
    else
    {
        return false;
    }
}




@end
