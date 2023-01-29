Shader "BlackHole/Clouds"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Cutoff", Range(0, 1)) = 0.5
        _CutoffSmooth ("Cutoff Smooth", Range(0, 1)) = 0
        _RotationSpeed ("Rotation Speed", Float) = 1
        _Color ("Color", Color) = (1, 1, 1, 1)
        _CapsFadePercentage ("Caps Fade Percentage", Range(0, 1)) = 0.3
        _CapsFadeSmooth ("Caps Fade Smooth", Range(0, 0.5)) = 0.2
        _FresnelMaskPower ("Fresnel Mask Power", Range(0, 5)) = 2
        
        [Header(BLEND)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _ScrBlend ("Source Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Destination Blend", float) = 1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        Blend [_ScrBlend] [_DstBlend]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_caps : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 view_direction : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            half _Cutoff;
            half _CutoffSmooth;
            half _RotationSpeed;
            half _CapsFadePercentage;
            half _CapsFadeSmooth;
            half _FresnelMaskPower;

            float compute_fresnel(const float3 normal, const float3 view_direction, const float power)
            {
                return pow(1 - saturate(dot(normalize(normal), normalize(view_direction))), power);
            }
            
            float3 rotate(float3 vertex)
            {
                float c = cos(_Time.y * _RotationSpeed);
                float s = sin(_Time.y * _RotationSpeed);
                
                float3x3 rotationMatrix = float3x3(c, 0, s,
                                                   0, 1, 0,
                                                  -s, 0, c);

                return mul(rotationMatrix, vertex);
            }

            float remap(const float remapped_value, const float2 in_range, const float2 out_range)
            {
                return out_range.x + (remapped_value - in_range.x) * (out_range.y - out_range.x) / (in_range.y - in_range.x);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_caps = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.view_direction = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Fresnel.
                float fresnel = compute_fresnel(i.normal, i.view_direction, _FresnelMaskPower);

                // Caps fade.
                float caps_mask = remap(i.uv_caps.y, float2(0, 1), float2(-1, 1));
                caps_mask = saturate(abs(caps_mask));
                caps_mask = smoothstep(caps_mask - _CapsFadeSmooth, caps_mask + _CapsFadeSmooth, _CapsFadePercentage);

                fixed4 col = tex2D(_MainTex, i.uv + float2(_Time.y * _RotationSpeed, 0));
                col = smoothstep(_Cutoff - _CutoffSmooth, _Cutoff + _CutoffSmooth, col);
                col += (1 - caps_mask) + fresnel;
                col *= _Color * _Color.a;
                col = saturate(col);

                return col;
            }
            
            ENDCG
        }
    }
}
