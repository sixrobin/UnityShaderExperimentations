// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/GrayscaleRGB" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_color ("Primary Color", int) = 0
		_smoothless ("Smoothness", float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	int _color;
	float _smoothness;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float3 sum = (float3)0;
        sum = tex2D(_MainTex, i.uv).rgb;

        float3 grayscale = dot(sum.rgb, 1) * 0.33;
		float threshold;

		if (_color == 0)
			threshold = smoothstep(0.0f, _smoothness, sum.r - grayscale);
		if (_color == 1)
			threshold = smoothstep(0.0f, _smoothness, sum.g - grayscale);
		if (_color == 2)
			threshold = smoothstep(0.0f, _smoothness, sum.b - grayscale);

        grayscale = pow(grayscale * 1, 1);

		float3 oCol = (float3)0;
        oCol = lerp(grayscale, sum, threshold);

        return fixed4(pow(float4(oCol, 1), 1));
	}

	ENDCG 
	
	Subshader 
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
	Fallback off	
}
