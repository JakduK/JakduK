package com.jakduk.dao;

import org.springframework.data.annotation.Id;

import com.jakduk.model.embedded.BoardStatus;

public class BoardFreeOnBest {
	
	@Id
	private String id;
	
	private int seq;
	
	private BoardStatus status;
	
	private String subject;
	
	private Integer count;
	
	private int views;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public int getSeq() {
		return seq;
	}

	public void setSeq(int seq) {
		this.seq = seq;
	}

	public BoardStatus getStatus() {
		return status;
	}

	public void setStatus(BoardStatus status) {
		this.status = status;
	}

	public String getSubject() {
		return subject;
	}

	public void setSubject(String subject) {
		this.subject = subject;
	}

	public Integer getCount() {
		return count;
	}

	public void setCount(Integer count) {
		this.count = count;
	}

	public int getViews() {
		return views;
	}

	public void setViews(int views) {
		this.views = views;
	}

	@Override
	public String toString() {
		return "BoardFreeOnBest [id=" + id + ", seq=" + seq + ", status="
				+ status + ", subject=" + subject + ", count=" + count
				+ ", views=" + views + "]";
	}

}