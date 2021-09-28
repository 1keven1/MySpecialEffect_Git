Shader "Dissolve/DissolveFire"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 0)
        _EdgeColor ("Edge Color", Color) = (1, 0, 0, 0)
        _EdgeIntensity ("Edge Intensity", Float) = 10
        _DissolveTex ("DIssolve Texture", 2D) = "gray" {}
        //_DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0
        _EdgeSharpness ("Edge Sharpness", Range(0, 1)) = 0.1
        _Offset ("Offset", Float) = 0
        _Speed ("Speed", Vector) = (0, 0, 0, 0)
        _Angle ("Angle", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
        Cull Off

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade
        #pragma target 3.0

        fixed4 _Color;
        fixed4 _EdgeColor;
        float _EdgeIntensity;
        sampler2D _DissolveTex;
        //fixed _DissolveAmount;
        fixed _EdgeSharpness;
        float _Offset;
        float4 _Speed;
        float _Angle;

        struct Input
        {
            float2 uv_DissolveTex;
        };
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed2x2 rotator = {cos(_Angle), -sin(_Angle), sin(_Angle), cos(_Angle)};
            float2 uv = mul(rotator, IN.uv_DissolveTex - fixed2(0.5, 0.5)) + fixed2(0.5, 0.5);
            uv = uv + float2(_Offset, 0);
            fixed dissolveAmount = uv.x;
            
            // 映射
            float smoothStepMin = dissolveAmount * (1 + _EdgeSharpness) - _EdgeSharpness;
            float smoothStepMax = smoothStepMin + _EdgeSharpness;
            
            // 贴图采样
            fixed dissolve = tex2D(_DissolveTex, uv + _Time.y * _Speed.xy).r;
            fixed alpha = saturate(smoothstep(smoothStepMin, smoothStepMax, dissolve));
            fixed edge = frac(alpha);
            // 着色
            o.Alpha = alpha;
            o.Emission = _Color + edge * _EdgeColor * _EdgeIntensity;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
