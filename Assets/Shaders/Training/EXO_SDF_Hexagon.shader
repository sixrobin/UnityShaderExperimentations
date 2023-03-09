Shader "EXO/SDF/Hexagon"
{
    Properties
    {
        [Header(GENERAL)]
        [Space(5)]
        _Diameter ("Diameter", Range(0, 1)) = 1
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainTextureRotation ("Main Texture Rotation", Range(0, 360)) = 0
        
        [Header(OUTLINE)]
        [Space(5)]
        _OutlineColor ("Outline Color", Color) = (0,0,0,0)
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.1
        _OutlineSmooth ("Outline Smooth", Range(0, 10)) = 1
        
        [Header(INNER GLOW)]
        [Space(5)]
        _InnerGlowColor ("Inner Glow Color", Color) = (1,1,1,1)
        _InnerGlowWidth ("Inner Glow Width", Range(0, 1)) = 0.1
        _InnerGlowSmooth ("Inner Glow Smooth", Range(0, 10)) = 1
        
        [Header(GENERAL)]
        [Space(5)]
        _DissolveMask ("Dissolve Mask", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        Zwrite Off
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define HEX_RATIO 1.73205 // sqrt(3)
            #define DEG_2_RAD 0.01745

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // General.
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _MainTextureRotation;
            half _Diameter;

            // Outline.
            fixed4 _OutlineColor;
            half _OutlineWidth;
            half _OutlineSmooth;
            
            // Inner glow.
            fixed4 _InnerGlowColor;
            half _InnerGlowWidth;
            half _InnerGlowSmooth;

            // Dissolve.
            sampler2D _DissolveMask;
            float4 _DissolveMask_ST;
            half _DissolveAmount;
            
            float2 rotate_uv(const float2 uv, const float theta)
            {
                float c = cos(theta * DEG_2_RAD);
                float s = sin(theta * DEG_2_RAD);
                float2x2 rotation_matrix = { +c, -s, +s, +c };
                return mul(rotation_matrix, uv);
            }

            float2 rotate_uv(const float2 uv, const float theta, float2 mid)
			{
				float c = cos(theta * DEG_2_RAD);
				float s = sin(theta * DEG_2_RAD);
			    return float2(c * (uv.x - mid.x) + s * (uv.y - mid.y) + mid.x, c * (uv.y - mid.y) - s * (uv.x - mid.x) + mid.y);
			}
            
            float hexagonal_distance(float2 uv)
            {
                uv = abs(uv);
                return max(dot(uv, normalize(float2(1, HEX_RATIO))), uv.x);
            }

            float compute_mask(float hex_dist, float width, float smooth)
            {
                half smoothstep_width = width * 0.5 * smooth;
                return 1 - smoothstep(hex_dist - smoothstep_width, hex_dist + smoothstep_width, (1 - width) * 0.5 * 1.73);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                // Hexagonal SDF and masks.
                float radius = _Diameter * 0.5;
                float hex_dist = hexagonal_distance((i.uv - 0.5) * 2); // Compute in vertex shader?
                float hex_mask = step(hex_dist, radius * HEX_RATIO);
                float inner_glow_mask = compute_mask(hex_dist / _Diameter, _InnerGlowWidth, _InnerGlowSmooth);
                float outline_mask = compute_mask(hex_dist / _Diameter, _OutlineWidth, _OutlineSmooth);

                // Main texture.
                float4 main_tex = tex2D(_MainTex, rotate_uv(i.uv, _MainTextureRotation, 0.5));

                // Final color computation.
                float4 color = main_tex;
                color = lerp(color, _InnerGlowColor, inner_glow_mask * _InnerGlowColor.a);
                color = lerp(color, _OutlineColor, outline_mask * _OutlineColor.a);
                
                return fixed4(color.rgb, hex_mask);
            }
            
            ENDCG
        }
    }
}
