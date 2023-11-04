#define DEG_2_RAD 0.01745

float InverseLerp(float a, float b, float v)
{
    return (v - a) / (b - a);
}
float2 InverseLerp(float2 a, float2 b, float2 v)
{
    return (v - a) / (b - a);
}
float3 InverseLerp(float3 a, float3 b, float3 v)
{
    return (v - a) / (b - a);
}
float4 InverseLerp(float4 a, float4 b, float4 v)
{
    return (v - a) / (b - a);
}

float Mod(float a, float n)
{
    return (a % n + n) % n;
}
float2 Mod(float2 a, float2 n)
{
    return (a % n + n) % n;
}
float3 Mod(float3 a, float3 n)
{
    return (a % n + n) % n;
}
float4 Mod(float4 a, float4 n)
{
    return (a % n + n) % n;
}

float Remap(float value, float from1, float to1, float from2, float to2)
{
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
}
float2 Remap(float2 value, float2 from1, float2 to1, float2 from2, float2 to2)
{
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
}
float3 Remap(float3 value, float3 from1, float3 to1, float3 from2, float3 to2)
{
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
}
float4 Remap(float4 value, float4 from1, float4 to1, float4 from2, float4 to2)
{
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
}

float4 InverseQuaternion(float4 q)
{
    return float4(-q.x, -q.y, -q.z, q.w);
}

float2 RotateVector2(float2 v, float theta)
{
    float c = cos(theta * DEG_2_RAD);
    float s = sin(theta * DEG_2_RAD);
    float2x2 rotation_matrix = { +c, -s, +s, +c };
    return mul(rotation_matrix, v);
}
float2 RotateVector2(float2 v, float theta, float pivot)
{
    float c = cos(theta * DEG_2_RAD);
    float s = sin(theta * DEG_2_RAD);
    return float2(c * (v.x - pivot) + s * (v.y - pivot) + pivot, c * (v.y - pivot) - s * (v.x - pivot) + pivot);
}
float2 RotateVector2(float2 v, float theta, float2 pivot)
{
    float c = cos(theta * DEG_2_RAD);
    float s = sin(theta * DEG_2_RAD);
    return float2(c * (v.x - pivot.x) + s * (v.y - pivot.y) + pivot.x, c * (v.y - pivot.y) - s * (v.x - pivot.x) + pivot.y);
}

float2 DirectionFromDegrees(float degrees)
{
    return float2(sin(degrees * DEG_2_RAD), cos(degrees * DEG_2_RAD));
}