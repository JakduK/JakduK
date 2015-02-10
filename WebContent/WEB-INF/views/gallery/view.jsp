<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>   
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
 
<!DOCTYPE html>
<html ng-app="jakdukApp">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>${gallery.name} - <spring:message code="gallery"/> &middot; <spring:message code="common.jakduk"/></title>
	<jsp:include page="../include/html-header.jsp"></jsp:include>
</head>

<body>
<div class="container jakduk-gallery">
<jsp:include page="../include/navigation-header.jsp"/>

<div class="form-group">
	<button type="button" class="btn btn-default" onclick="location.href='<c:url value="/gallery"/>'">
		<span class="glyphicon glyphicon-th-large"></span>
	</button>
	<c:choose>
		<c:when test="${!empty prev}">
			<button type="button" class="btn btn-default" onclick="location.href='<c:url value="/gallery/view/${prev.id}"/>'">
				<span class="glyphicon glyphicon-chevron-left"></span>
			</button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn btn-default" disabled="disabled">
				<span class="glyphicon glyphicon-chevron-left"></span>
			</button>		
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${!empty next}">
			<button type="button" class="btn btn-default" onclick="location.href='<c:url value="/gallery/view/${next.id}"/>'">
				<span class="glyphicon glyphicon-chevron-right"></span>
			</button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn btn-default" disabled="disabled">
				<span class="glyphicon glyphicon-chevron-right"></span>
			</button>		
		</c:otherwise>
	</c:choose>	
</div>

<%@page import="java.util.Date"%>
<%Date CurrentDate = new Date();%>
<fmt:formatDate var="nowDate" value="<%=CurrentDate %>" pattern="yyyy-MM-dd" />
<fmt:formatDate var="postDate" value="${createDate[gallery.id]}" pattern="yyyy-MM-dd" />
					
<blockquote>
  ${gallery.name}
  <h5><span class="glyphicon glyphicon-user"></span> ${gallery.writer.username}</h5>
  <h5>
  	<span class="glyphicon glyphicon-time"></span>
		<c:choose>
			<c:when test="${postDate < nowDate}">
				<fmt:formatDate value="${createDate[gallery.id]}" pattern="${dateTimeFormat.date}" />
			</c:when>
			<c:otherwise>
				<fmt:formatDate value="${createDate[gallery.id]}" pattern="${dateTimeFormat.time}" />
			</c:otherwise>
		</c:choose>
		|
  	<span class="glyphicon glyphicon-eye-open"></span> ${gallery.views}
  </h5>
</blockquote>

<img class="img-responsive" src="<%=request.getContextPath()%>/gallery/${gallery.id}">

<hr/>

<h4><spring:message code="gallery.linked.posts"/></h4>
<ul>
	<c:forEach items="${linkedPosts}" var="post">
	<fmt:formatDate var="postDate" value="${createDate[post.id]}" pattern="yyyy-MM-dd" />
	
		<li>
			<a href="<c:url value="/board/free/${post.seq}"/>">${post.subject}</a> 
			| <span class="glyphicon glyphicon-user"></span> ${post.writer.username}
			|
	  	<span class="glyphicon glyphicon-time"></span>
			<c:choose>
				<c:when test="${postDate < nowDate}">
					<fmt:formatDate value="${createDate[post.id]}" pattern="${dateTimeFormat.date}" />
				</c:when>
				<c:otherwise>
					<fmt:formatDate value="${createDate[post.id]}" pattern="${dateTimeFormat.time}" />
				</c:otherwise>
			</c:choose>			
		</li>
	</c:forEach>
</ul>

<hr/>

<div class="form-group">
	<button type="button" class="btn btn-default" onclick="location.href='<c:url value="/gallery"/>'">
		<span class="glyphicon glyphicon-th-large"></span>
	</button>
	<c:choose>
		<c:when test="${!empty prev}">
			<button type="button" class="btn btn-default" onclick="location.href='<c:url value="/gallery/view/${prev.id}"/>'">
				<span class="glyphicon glyphicon-chevron-left"></span>
			</button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn btn-default" disabled="disabled">
				<span class="glyphicon glyphicon-chevron-left"></span>
			</button>		
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${!empty next}">
			<button type="button" class="btn btn-default" onclick="location.href='<c:url value="/gallery/view/${next.id}"/>'">
				<span class="glyphicon glyphicon-chevron-right"></span>
			</button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn btn-default" disabled="disabled">
				<span class="glyphicon glyphicon-chevron-right"></span>
			</button>		
		</c:otherwise>
	</c:choose>	
</div>

<jsp:include page="../include/footer.jsp"/>
</div><!-- /.container -->

<!-- Bootstrap core JavaScript
  ================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
<script src="<%=request.getContextPath()%>/resources/jquery/js/jquery.min.js"></script>
<script src="<%=request.getContextPath()%>/resources/bootstrap/js/bootstrap.min.js"></script>    

<script type="text/javascript">
var jakdukApp = angular.module("jakdukApp", []);
</script>

<jsp:include page="../include/body-footer.jsp"/>

</body>

</html>