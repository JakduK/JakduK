package com.jakduk.api.common.util;

import com.jakduk.api.common.vo.AttemptSocialUser;
import com.jakduk.core.common.CoreConst;
import com.jakduk.core.exception.ServiceError;
import com.jakduk.core.exception.ServiceException;
import io.jsonwebtoken.*;
import org.apache.commons.lang3.StringUtils;
import org.springframework.aop.AopInvocationException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mobile.device.Device;
import org.springframework.stereotype.Component;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Component
public class JwtTokenUtils implements Serializable {

    private static final long serialVersionUID = -3301605591108950415L;

    private final String CLAIM_KEY_USER_ID = "uid";
    private final String CLAIM_KEY_NAME = "name";
    private final String CLAIM_KEY_PROVIDER_ID = "pid";
    private final String AUDIENCE_UNKNOWN = "unknown";
    private final String AUDIENCE_WEB = "web";
    private final String AUDIENCE_MOBILE = "mobile";
    private final String AUDIENCE_TABLET = "tablet";

    @Value("${jwt.token.secret}")
    private String secret;

    @Value("${jwt.token.expiration}")
    private Long expiration;

    public String getUsernameFromToken(String token) {
        final Claims claims = getClaimsFromToken(token);

        return claims.getIssuer();
    }

    public String getProviderIdFromToken(String token) {
        final Claims claims = getClaimsFromToken(token);

        return (String) claims.get(CLAIM_KEY_PROVIDER_ID);
    }

    public Date getExpirationDateFromToken(String token) {
        final Claims claims = getClaimsFromToken(token);

        return claims.getExpiration();
    }

    public String getAudienceFromToken(String token) {

        final Claims claims = getClaimsFromToken(token);

        return (String) claims.get(Claims.AUDIENCE);
    }

    public AttemptSocialUser getAttemptedFromToken(String token) {

        AttemptSocialUser attemptSocialUser = new AttemptSocialUser();

        try {
            final Claims claims = getClaimsFromToken(token);

            if (claims.containsKey("id"))
                attemptSocialUser.setId(claims.get("id", String.class));

            if (claims.containsKey("email"))
                attemptSocialUser.setEmail(claims.get("email", String.class));

            if (claims.containsKey("username"))
                attemptSocialUser.setUsername(claims.get("username", String.class));

            if (claims.containsKey("providerId")) {
                String temp = claims.get("providerId", String.class);
                attemptSocialUser.setProviderId(CoreConst.ACCOUNT_TYPE.valueOf(temp));
            }

            if (claims.containsKey("providerUserId"))
                attemptSocialUser.setProviderUserId(claims.get("providerUserId", String.class));

            if (claims.containsKey("externalSmallPictureUrl"))
                attemptSocialUser.setExternalSmallPictureUrl(claims.get("externalSmallPictureUrl", String.class));

            if (claims.containsKey("externalLargePictureUrl"))
                attemptSocialUser.setExternalLargePictureUrl(claims.get("externalLargePictureUrl", String.class));

        } catch (Exception ignored) {
        }

        return attemptSocialUser;
    }

    private Claims getClaimsFromToken(String token) {

        Claims claims;

        try {
            claims = Jwts.parser()
                    .setSigningKey(secret)
                    .parseClaimsJws(token)
                    .getBody();
        } catch (IllegalArgumentException e) {
            claims = null;
        } catch (ExpiredJwtException e) {
            throw new ServiceException(ServiceError.EXPIRATION_TOKEN, e);
        } catch (MalformedJwtException e) {
            throw new ServiceException(ServiceError.INVALID_TOKEN, e);
        }  catch (Exception e) {
            e.printStackTrace();
            throw new ServiceException(ServiceError.INTERNAL_SERVER_ERROR, e);
        }

        return claims;
    }

    private Date generateExpirationDate() {
        return new Date(System.currentTimeMillis() + expiration * 1000);
    }

    private Boolean isTokenExpired(String token) {

        try {
            final Date expiration = getClaimsFromToken(token).getExpiration();

            return expiration.before(new Date());

        } catch (ExpiredJwtException e) {
            return true;
        }
    }

    private String generateAudience(Device device) {
        String audience = AUDIENCE_UNKNOWN;

        try {
            if (device.isNormal()) {
                audience = AUDIENCE_WEB;
            } else if (device.isTablet()) {
                audience = AUDIENCE_TABLET;
            } else if (device.isMobile()) {
                audience = AUDIENCE_MOBILE;
            }
        } catch (AopInvocationException | NullPointerException ignored) {
        }

        return audience;
    }

    private Boolean ignoreTokenExpiration(String token) {
        String audience = getAudienceFromToken(token);

        return (AUDIENCE_TABLET.equals(audience) || AUDIENCE_MOBILE.equals(audience));
    }

    /**
     * 토큰 생성
     *
     * @param device
     * @param id
     * @param email
     * @param username
     * @param providerId
     */
    public String generateToken(Device device, String id, String email, String username, String providerId) {

        Map<String, Object> claims = new HashMap<>();
        claims.put(Claims.ISSUER, email);
        claims.put(Claims.AUDIENCE, generateAudience(device));
        claims.put(CLAIM_KEY_USER_ID, id);
        claims.put(CLAIM_KEY_NAME, username);
        claims.put(CLAIM_KEY_PROVIDER_ID, providerId);

        return generateToken(claims, generateExpirationDate());
    }

    public String generateAttemptedToken(AttemptSocialUser attemptSocialUser) {

        return generateToken(convertAttemptedSocialUserToMap(attemptSocialUser),
                new Date(System.currentTimeMillis() + 600 * 1000));
    }

    private String generateToken(Map<String, Object> claims, Date expirationDate) {

        return Jwts.builder()
                .setClaims(claims)
                .setExpiration(expirationDate)
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }

    public Boolean canTokenBeRefreshed(String token) {
        return (! isTokenExpired(token) || ignoreTokenExpiration(token));
    }

    public String refreshToken(String token) {
        String refreshedToken;
        try {
            final Claims claims = getClaimsFromToken(token);
            refreshedToken = generateToken(claims, generateExpirationDate());
        } catch (Exception e) {
            refreshedToken = null;
        }
        return refreshedToken;
    }

    public Boolean isValidateToken(String token, String email) {
        String username = this.getUsernameFromToken(token);

        return (username.equals(email) && ! isTokenExpired(token));
    }

    public Boolean isValidateToken(String token) {

        return ! isTokenExpired(token);
    }

    private Map<String, Object> convertAttemptedSocialUserToMap(AttemptSocialUser attemptSocialUser) {
        Map<String, Object> attempted = new HashMap<>();

        if (StringUtils.isNotBlank(attemptSocialUser.getId()))
            attempted.put("id", attemptSocialUser.getId());

        if (StringUtils.isNotBlank(attemptSocialUser.getEmail()))
            attempted.put("email", attemptSocialUser.getEmail());

        if (StringUtils.isNotBlank(attemptSocialUser.getUsername()))
            attempted.put("username", attemptSocialUser.getUsername());

        if (Objects.nonNull(attemptSocialUser.getProviderId()))
            attempted.put("providerId", attemptSocialUser.getProviderId());

        if (StringUtils.isNotBlank(attemptSocialUser.getProviderUserId()))
            attempted.put("providerUserId", attemptSocialUser.getProviderUserId());

        if (StringUtils.isNotBlank(attemptSocialUser.getExternalSmallPictureUrl()))
            attempted.put("externalSmallPictureUrl", attemptSocialUser.getExternalSmallPictureUrl());

        if (StringUtils.isNotBlank(attemptSocialUser.getExternalLargePictureUrl()))
            attempted.put("externalLargePictureUrl", attemptSocialUser.getExternalLargePictureUrl());

        return attempted;
    }
}
