// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Pixel" {

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_gridColor("Grid Color", float) = 0
		_scale("Pixel Scale", int) = 10
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
		float2 uv		: TEXCOORD0;
		float4 vertex	: SV_POSITION;
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
	half4 _gridColor;
	uint _scale;

	fixed4 frag (v2f i) : SV_Target
	{
		float2 texel = _MainTex_TexelSize.xy * _scale/2;
		float2 uv = i.uv.xy/texel;
		float4 sum = tex2D(_MainTex, floor(uv/2) * 2 * texel);

		float x = i.uv.x;
		float y = i.uv.y;
		fixed4 color = _gridColor;

		x = x * _ScreenParams.xy.x;
		int x2 = int(x);
		y = y * _ScreenParams.xy.y;
		int y2 = int(y);
			
		fixed3 col = fixed3(sqrt(color.x - sum.r), sqrt(color.y - sum.g), sqrt(color.z - sum.b));

		if(x2%_scale == 0)
			sum = fixed4(sum.r + col.x, sum.g + col.y, sum.b + col.z, 1);
				
		if(y2%_scale == 0)			
			sum = fixed4(sum.r + col.x, sum.g + col.y, sum.b + col.z, 1);
				
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
