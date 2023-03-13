// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/CleanPixel" {

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_volume("Color Volume", float) = 0
		_global("Global Illumination", float) = 0
		_scale("Pixel Scale", int) = 10
		_threshold("Threshold", float) = 0.5
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct appdata
	{
		float4 vertex	: POSITION;
		float2 uv		: TEXCOORD0;
	};

	struct v2f
	{
		float4 vertex	: SV_POSITION;
		float2 uv		: TEXCOORD0;
	};

	v2f vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}
			
	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	float4 _volume;
	float4 _global;
	uint _scale;
	float _threshold;

	fixed4 frag (v2f i) : SV_Target
	{
		float2 texel = _MainTex_TexelSize.xy * _scale/2;
		float2 uv = i.uv.xy/texel;
		float4 sum = tex2D(_MainTex, floor(uv/2) * 2 * texel);

		float x = i.uv.x;
		float y = i.uv.y;

		x = x * _ScreenParams.xy.x;
		int x2 = int(x);
		y = y * _ScreenParams.xy.y;
		int y2 = int(y);
			
		fixed3 col = fixed3((_volume.x - sum.r), (_volume.y - sum.g), (_volume.z - sum.b));

		if(x2%_scale == 0)
			sum = fixed4(sum.r + col.x, sum.g + col.y, sum.b + col.z, 1);
				
		if(y2%_scale == 0)			
			sum = fixed4(sum.r + col.x, sum.g + col.y, sum.b + col.z, 1);
		
		sum.rgb = (sum.r + sum.g + sum.b) / 3;

		if (sum.r < _threshold)
			sum.r = _volume.r;
		else
			sum.r = _global.r;

		if (sum.g < _threshold)
			sum.g = _volume.g;
		else
			sum.g = _global.g;

		if (sum.b < _threshold)
			sum.b = _volume.b;
		else
			sum.b = _global.b;

		return fixed4(sum);
	}

	ENDCG

	SubShader 
	{
		Pass 
		{
			ZTest Always
			Cull Off 
			ZWrite Off 

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
