Shader "MyShaders/Ascii" {
    
	Properties
	{
		_MainTex("Source Image", 2D) = "" {}
		_scale("Scale Factor", int) = 2
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	int _scale;

	struct v2f
	{
		float4 position : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	float character(float n, float2 p)
	{
		p = floor(p * float2(4, -4) + float2(2, 2));

		if (clamp(p.x, 0, 4) == p.x && clamp(p.y, 0, 4) == p.y)
		{
			float c = fmod(n / exp2(p.x + 5 * p.y), 2);

			if (int(c) == 1) 
				return 1;
		}
		return 0;
	}

	float4 frag(v2f i) : SV_Target
	{
		float2 texel = _MainTex_TexelSize.xy * _scale;
		float2 uv = i.uv.xy / texel;
		float3 sum = tex2D(_MainTex, floor(uv / 8) * 8 * texel).rgb;

		float gray = (sum.r + sum.g + sum.b) / 3;		
		float n = (float)0;

		/*
		1        2        4        8        16
		32       64       128      256      512
		1024     2048     4096     8192     16384
		32768    65536    131072   262144   524288
		1048576  2097152  4194304  8388608  167772016
		*/

		if (gray > 0.1f)
			n = 65536;     // .
		if (gray > 0.2f) 
			n = 65600;    // :
		if (gray > 0.3f) 
			n = 332772;   // *
		if (gray > 0.4f) 
			n = 15255086; // o
		if (gray > 0.5f) 
			n = 23385164; // &
		if (gray > 0.6f) 
			n = 15252014; // 8
		if (gray > 0.7f) 
			n = 13199452; // G
		if (gray > 0.8f) 
			n = 11512810; // #
		if (gray > 0.9f)
			n = 992;      // _

		float2 p = fmod(uv/4, 2) - 1;
#ifdef PIXELATED
		sum += character(n, p);
#else
		sum *= character(n, p);
#endif
		float4 _color = (float4)1;
		float4 src = tex2D(_MainTex, i.uv.xy);
		float4 ascii = lerp(src, float4(sum * _color.rgb, 1), 1);

		return fixed4(ascii);
	}

	ENDCG

    SubShader 
	{
        Pass 
		{
            ZTest Always 
			Cull Off 
			ZWrite Off
            Fog { Mode off }

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag
			#pragma shader_feature PIXELATED
            ENDCG
        }
    }
}
