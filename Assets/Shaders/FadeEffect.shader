Shader "Unlit/FadeEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        _ParticleTex ("Particle Texture", 2D) = "white" {}
		_ParticleSize ("Particle Size", Range(1, 20)) = 8
		_Frequency ("Frequency", Float) = 3
		_Speed ("Speed", Range(0, 30)) = 3
		_Amplitude ("Amplitude", Range(0, 10)) = 1
		_Color1 ("Color 1", Color) = (1, 0.4, 0, 1)
		_Color2 ("Color 2", Color) = (0, 1, 1, 1)
		_FadeRate ("Fade Rate", Range(0.5, 1)) = 0.98
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Transparent" 
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Fog { Mode Off }
        Lighting Off
        ZTest Always

        // Pass 1: Add the particles from Main Texture
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
   
            #include "UnityCG.cginc"
  
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ParticleTex;
			float _ParticleSize;
			float _Frequency;
			float _Speed;
			float _Amplitude;
			fixed4 _Color1;
			fixed4 _Color2;
   
 			static const float PI = 3.14159;

			fixed4 frag (v2f_img i) : SV_Target
			{
				// Get time parameter
				float max_time = _ParticleSize + 1;
				float t = fmod(_Time.y * _Speed, max_time) - 1;

				// Scale particle uv coordinates an input to sin/cos functions
				float2 p_uv = i.uv * _ParticleSize;

				float sine = _Amplitude * sin(_Frequency * t);
				float cosine = _Amplitude * cos(_Frequency * t + PI/2);
					
				float2 sin_uv = float2(p_uv.x - t, p_uv.y - sine);
				float2 cos_uv = float2(p_uv.x - t, p_uv.y - cosine);

				fixed4 sin_particle = tex2D(_ParticleTex, sin_uv) * _Color1;
				fixed4 cos_particle = tex2D(_ParticleTex, cos_uv) * _Color2;

				// Grab pixel data from previous loop
				fixed4 main = tex2D(_MainTex, i.uv);

				// Prevent wrapped particle texture duplicates from showing up
				float lower = floor(_ParticleSize / 2.0);
				float upper = lower + 1;

				float time_step = step(t, p_uv.x) * step(p_uv.x, t + 1);
				float sin_step = step(sine + lower, p_uv.y) * step(p_uv.y, sine + upper);
				float cos_step = step(cosine + lower, p_uv.y) * step(p_uv.y, cosine + upper);

				fixed4 particles = time_step * (sin_particle * sin_step + cos_particle * cos_step);

				return main + particles;
			}

			ENDCG
		}

        // Pass 2: Fade first pass result onto Rendertexture 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
   
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _FadeRate;
   
            fixed4 frag (v2f_img i) : SV_Target
            {
                return tex2D(_MainTex, i.uv) * _FadeRate;
            }

            ENDCG
        }
    }
}